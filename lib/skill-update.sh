_native_backup_path() {
  printf '%s/.assistant-skill-backups/%s/%s\n' "$(dirname -- "$1")" "$2" "$3"
}

_native_with_lock() {
  local root="$1" name="$2" harness="$3" lock run_rc
  shift 3
  lock="$(dirname -- "$root")/.assistant-skill-locks/$harness-$name"
  _native_no_symlinks "$lock" || return 1
  mkdir -p -- "$(dirname -- "$lock")" || return 1
  mkdir -- "$lock" 2>/dev/null || { _native_error locked "$lock"; return 1; }
  "$@"
  run_rc=$?
  rmdir -- "$lock" || { _native_error failed "$lock"; return 1; }
  return "$run_rc"
}

_native_show_diff() {
  command -v diff >/dev/null 2>&1 || { _native_error diff "$1"; return 1; }
  local run_rc
  diff -u -L "$3" -L "$4" -- "$1" "$2"
  run_rc=$?
  [[ $run_rc -le 1 ]] || { _native_error failed "$1"; return 1; }
}

_native_source_notice() {
  local name="$1" source_file="$2" effective
  effective=$(_resolve_skill "$name" 2>/dev/null) || return 0
  [[ "$effective" == "$source_file" ]] || t_native_source_notice "$source_file" "$effective" >&2
}

# The transaction stays beside the skill root so directory moves share a filesystem.
# On a failed rollback, keep the transaction intact and report its recovery path.
_native_replace() {
  local destination="$1" package="$2" backup="$3" name="$4" harness="$5" scope="$6"
  local transaction
  _native_verify_files "$destination" "$name" "$harness" "$scope" || return 1
  _native_verify_files "$package" "$name" "$harness" "$scope" || return 1
  _native_no_symlinks "$backup" || return 1
  if [[ -e "$backup" ]]; then
    _native_verify_files "$backup" "$name" "$harness" "$scope" || return 1
  fi
  mkdir -p -- "$(dirname -- "$backup")" || return 1
  transaction=$(mktemp -d "$(dirname -- "$(dirname -- "$destination")")/.assistant-skill-transaction.XXXXXX") || return 1
  if ! mkdir -- "$transaction/next" || ! cp -- "$package/SKILL.md" "$package/.assistant-install.tsv" "$package/.assistant-install.sha256" "$transaction/next/"; then
    rm -rf -- "$transaction"
    _native_error failed "$destination"
    return 1
  fi
  _native_verify_files "$transaction/next" "$name" "$harness" "$scope" || { rm -rf -- "$transaction"; return 1; }
  if [[ -e "$backup" ]] && ! mv -- "$backup" "$transaction/older"; then
    rm -rf -- "$transaction"
    _native_error failed "$backup"
    return 1
  fi
  if [[ -d "$transaction/older" ]] && ! _native_verify_files "$transaction/older" "$name" "$harness" "$scope"; then
    mv -- "$transaction/older" "$backup" || { _native_error failed "$transaction"; return 1; }
    rm -rf -- "$transaction"
    return 1
  fi
  if ! mv -- "$destination" "$transaction/previous"; then
    if [[ -d "$transaction/older" ]]; then
      mv -- "$transaction/older" "$backup" || { _native_error failed "$transaction"; return 1; }
    fi
    rm -rf -- "$transaction"
    _native_error failed "$destination"
    return 1
  fi
  if _native_verify_files "$transaction/previous" "$name" "$harness" "$scope" && mv -- "$transaction/next" "$destination"; then
    if mv -- "$transaction/previous" "$backup"; then
      rm -rf -- "$transaction"
      return 0
    fi
    mv -- "$destination" "$transaction/next" || { _native_error failed "$transaction"; return 1; }
  fi
  mv -- "$transaction/previous" "$destination" || { _native_error failed "$transaction"; return 1; }
  if [[ -d "$transaction/older" ]]; then
    mv -- "$transaction/older" "$backup" || { _native_error failed "$transaction"; return 1; }
  fi
  rm -rf -- "$transaction"
  _native_error failed "$destination"
}

_native_update() {
  local name="$1" harness="$2" scope="$3" root="$4" dry_run="$5" renderer="$6" action="$7"
  local destination="$root/$name" source_file package backup run_rc version hash
  _native_verify_record "$destination" "$name" "$harness" "$scope" || return 1
  source_file=$(_native_record_value "$destination/.assistant-install.tsv" source)
  [[ -f "$source_file" ]] || { _native_error source_missing "$source_file"; return 1; }
  _native_source_notice "$name" "$source_file"
  package=$(mktemp -d) || return 1
  if ! _native_build_package "$name" "$harness" "$scope" "$source_file" "$renderer" "$package"; then
    rm -rf -- "$package"
    return 1
  fi
  _native_show_diff "$destination/SKILL.md" "$package/SKILL.md" "$destination/SKILL.md" "$source_file"
  run_rc=$?
  if [[ $run_rc -eq 0 && "$action" != diff ]]; then
    _native_verify_files "$destination" "$name" "$harness" "$scope" && _native_check_conflicts "$root" "$name" "$destination"
    run_rc=$?
    if [[ $run_rc -eq 0 ]]; then
      hash=$(_native_record_value "$package/.assistant-install.tsv" source_hash)
      if [[ "$hash" == "$(_native_record_value "$destination/.assistant-install.tsv" source_hash)" ]]; then
        t_native_current "$destination"
      else
        backup=$(_native_backup_path "$root" "$harness" "$name")
        _native_no_symlinks "$backup"
        run_rc=$?
        if [[ $run_rc -eq 0 && -e "$backup" ]]; then
          _native_verify_files "$backup" "$name" "$harness" "$scope"
          run_rc=$?
        fi
        if [[ $run_rc -eq 0 ]]; then
          if [[ "$dry_run" == yes ]]; then
            version=$(_native_record_value "$package/.assistant-install.tsv" source_version)
            t_native_plan update "$destination" "$source_file" "$version" "$hash"
          else
            _native_replace "$destination" "$package" "$backup" "$name" "$harness" "$scope"
            run_rc=$?
            [[ $run_rc -ne 0 ]] || t_native_done update "$destination"
          fi
        fi
      fi
    fi
  fi
  rm -rf -- "$package"
  return "$run_rc"
}

_native_restore() {
  local name="$1" harness="$2" scope="$3" root="$4" dry_run="$5" backup
  backup=$(_native_backup_path "$root" "$harness" "$name")
  _native_verify_files "$root/$name" "$name" "$harness" "$scope" || return 1
  [[ -d "$backup" ]] || { _native_error no_backup "$backup"; return 1; }
  _native_verify_files "$backup" "$name" "$harness" "$scope" || return 1
  _native_check_conflicts "$root" "$name" "$root/$name" || return 1
  _native_show_diff "$root/$name/SKILL.md" "$backup/SKILL.md" "$root/$name/SKILL.md" "$backup/SKILL.md" || return 1
  if [[ "$dry_run" == yes ]]; then
    t_native_plan restore "$root/$name" "$(_native_record_value "$backup/.assistant-install.tsv" source)" "$(_native_record_value "$backup/.assistant-install.tsv" source_version)" "$(_native_record_value "$backup/.assistant-install.tsv" installed_hash)"
  else
    _native_replace "$root/$name" "$backup" "$backup" "$name" "$harness" "$scope" || return 1
    t_native_done restore "$root/$name"
  fi
}

_native_remove() {
  local name="$1" harness="$2" scope="$3" root="$4" dry_run="$5" destination="$4/$1" backup
  backup=$(_native_backup_path "$root" "$harness" "$name")
  _native_verify_files "$destination" "$name" "$harness" "$scope" || return 1
  _native_no_symlinks "$backup" || return 1
  if [[ -e "$backup" ]]; then
    _native_verify_files "$backup" "$name" "$harness" "$scope" || return 1
  fi
  if [[ "$dry_run" == yes ]]; then
    t_native_plan remove "$destination" "$(_native_record_value "$destination/.assistant-install.tsv" source)" "$(_native_record_value "$destination/.assistant-install.tsv" source_version)" "$(_native_record_value "$destination/.assistant-install.tsv" installed_hash)"
  else
    if [[ -d "$backup" ]]; then
      rm -- "$backup/SKILL.md" "$backup/.assistant-install.tsv" "$backup/.assistant-install.sha256" && rmdir -- "$backup" || { _native_error failed "$backup"; return 1; }
    fi
    rm -- "$destination/SKILL.md" "$destination/.assistant-install.tsv" "$destination/.assistant-install.sha256" && rmdir -- "$destination" || { _native_error failed "$destination"; return 1; }
    t_native_done remove "$destination"
  fi
}

_cmd_skill_install() {
  local action="$1" name="" harness="" scope="" project="" project_set=no dry_run=no
  shift
  case "$action" in install|verify|remove|update|restore|diff|installed|status) ;; *) t_native_usage; return 1 ;; esac
  if [[ $# -gt 0 && "$1" != --* ]]; then name="$1"; shift; fi
  if [[ -n "$name" ]]; then
    [[ "$name" =~ ^[a-z0-9][a-z0-9_-]*$ ]] || { t_native_usage; return 1; }
  elif [[ "$action" != installed && "$action" != status ]]; then
    t_native_usage; return 1
  fi
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --harness|--scope|--project)
        [[ $# -ge 2 && -n "$2" && "$2" != --* ]] || { t_native_usage; return 1; }
        case "$1" in
          --harness) [[ -z "$harness" ]] || { t_native_usage; return 1; }; harness="$2" ;;
          --scope) [[ -z "$scope" ]] || { t_native_usage; return 1; }; scope="$2" ;;
          --project) [[ "$project_set" == no ]] || { t_native_usage; return 1; }; project="$2"; project_set=yes ;;
        esac
        shift 2 ;;
      --dry-run) [[ "$dry_run" == no ]] || { t_native_usage; return 1; }; dry_run=yes; shift ;;
      *) t_native_usage; return 1 ;;
    esac
  done
  [[ "$harness" =~ ^[a-z0-9][a-z0-9_-]*$ ]] || { t_native_usage; return 1; }
  case "$action" in installed|status) scope="${scope:-all}" ;; esac
  [[ -n "$harness" && ( "$scope" == project || "$scope" == user || ( "$scope" == all && ( "$action" == installed || "$action" == status ) ) ) && ( "$scope" != user || "$project_set" == no ) ]] || { t_native_usage; return 1; }
  case "$action" in verify|diff|installed|status) [[ "$dry_run" == no ]] || { t_native_usage; return 1; } ;; esac
  _harness_require "$harness" native_skills || return 1
  local clean_harness root_func renderer root source_file context roots run_rc
  clean_harness=$(_sanitize_engine_name "$harness")
  root_func="_engine_${clean_harness}_skill_root"
  renderer="_engine_${clean_harness}_render_skill"
  command -v "$root_func" >/dev/null 2>&1 && command -v "$renderer" >/dev/null 2>&1 || { _native_error unsupported "$harness"; return 1; }
  context="${project:-$PWD}"
  context=$(cd -- "$context" && pwd -P) || { _native_error invalid "$context"; return 1; }
  if [[ "$scope" == project ]]; then
    if [[ "$project_set" == no ]]; then project=$(git rev-parse --show-toplevel 2>/dev/null) || project="$PWD"; fi
    project=$(cd -- "$project" && pwd -P) || { _native_error invalid "$project"; return 1; }
  fi
  roots=$(_native_discovery_roots "$harness" "$context") || return 1
  if [[ "$action" == installed || "$action" == status ]]; then
    _native_inventory "$roots" "$name" "$harness" "$scope" "$action"
    return $?
  fi
  root=$("$root_func" "$scope" "$project") || return 1
  [[ "$root" == /* && "$root" != *$'\t'* && "$root" != *$'\n'* ]] || { _native_error invalid "$root"; return 1; }
  _native_no_symlinks "$root" || return 1
  _native_cross_scope_notice "$roots" "$name" "$root" || return 1
  case "$action" in
    install)
      _skill_is_reserved "$name" && { _native_error reserved "$name"; return 1; }
      source_file=$(_resolve_skill "$name") || { _native_error invalid "$name"; return 1; }
      [[ "$source_file" != *$'\t'* && "$source_file" != *$'\n'* ]] || { _native_error invalid "$source_file"; return 1; }
      ;;
    verify)
      _native_verify_files "$root/$name" "$name" "$harness" "$scope" && _native_check_conflicts "$root" "$name" "$root/$name" || return 1
      t_native_done verify "$root/$name"
      return 0 ;;
    diff) _native_update "$name" "$harness" "$scope" "$root" no "$renderer" diff; return $? ;;
  esac
  local runner=()
  [[ "$dry_run" == yes ]] || runner=(_native_with_lock "$root" "$name" "$harness")
  case "$action" in
    install) "${runner[@]}" _native_install "$name" "$harness" "$scope" "$root" "$dry_run" "$source_file" "$renderer" ;;
    update) "${runner[@]}" _native_update "$name" "$harness" "$scope" "$root" "$dry_run" "$renderer" update ;;
    restore) "${runner[@]}" _native_restore "$name" "$harness" "$scope" "$root" "$dry_run" ;;
    remove) "${runner[@]}" _native_remove "$name" "$harness" "$scope" "$root" "$dry_run" ;;
  esac
  run_rc=$?
  return "$run_rc"
}
