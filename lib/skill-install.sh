_native_error() {
  t_native_error "$(t_native_reason "$1")" "${2:-}" >&2
  return 1
}

_native_digest() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum < "$1" | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 < "$1" | awk '{print $1}'
  else
    _native_error checksum "$1"
  fi
}

_native_no_symlinks() {
  local cursor="$1"
  while [[ "$cursor" != / && "$cursor" != . ]]; do
    [[ ! -L "$cursor" ]] || { _native_error symlink "$cursor"; return 1; }
    cursor=$(dirname -- "$cursor")
  done
}

_native_record_value() {
  awk -F '\t' -v key="$2" '$1 == key { print $2 }' "$1"
}

_native_source_version() {
  local directory version
  directory=$(dirname -- "$1")
  if command -v git >/dev/null 2>&1 && git -C "$directory" ls-files --error-unmatch -- SKILL.md >/dev/null 2>&1; then
    version=$(git -C "$directory" rev-parse HEAD) || return 1
    git -C "$directory" diff --quiet HEAD -- SKILL.md || version="${version}:modified"
    printf '%s\n' "$version"
  else
    printf '%s\n' unversioned
  fi
}

_native_verify_files() {
  local destination="$1" name="$2" harness="$3" scope="$4" record checksum expected actual extra
  record="$destination/.assistant-install.tsv"
  checksum="$destination/.assistant-install.sha256"
  _native_no_symlinks "$destination" || return 1
  [[ -d "$destination" && -f "$destination/SKILL.md" && ! -L "$destination/SKILL.md" && -f "$record" && ! -L "$record" && -f "$checksum" && ! -L "$checksum" ]] || {
    _native_error unmanaged "$destination"; return 1;
  }
  # Exactly one value for every known field; provenance is never sourced.
  if ! awk -F '\t' 'BEGIN { split("format harness scope name source source_version source_hash installed_hash renderer", keys, " "); for (i in keys) allowed[keys[i]]=1 }
    NF != 2 || !($1 in allowed) || $2 == "" || seen[$1]++ { bad=1 }
    END { if (bad || NR != 9) exit 1 }' "$record"; then
    _native_error unmanaged "$record"
    return 1
  fi
  expected=$(cat "$checksum")
  actual=$(_native_digest "$record") || return 1
  [[ "$expected" =~ ^[a-f0-9]{64}$ && "$actual" == "$expected" ]] || { _native_error edited "$record"; return 1; }
  [[ "$(_native_record_value "$record" format)" == 1 && "$(_native_record_value "$record" renderer)" == 1 && "$(_native_record_value "$record" harness)" == "$harness" && "$(_native_record_value "$record" scope)" == "$scope" && "$(_native_record_value "$record" name)" == "$name" ]] || {
    _native_error unmanaged "$record"; return 1;
  }
  expected=$(_native_record_value "$record" installed_hash)
  actual=$(_native_digest "$destination/SKILL.md") || return 1
  [[ "$actual" == "$expected" ]] || { _native_error edited "$destination/SKILL.md"; return 1; }
  local metadata
  metadata=$(_skill_metadata "$destination/SKILL.md") || { _native_error invalid "$destination/SKILL.md"; return 1; }
  [[ "${metadata%%$'\t'*}" == "$name" ]] || { _native_error invalid "$destination/SKILL.md"; return 1; }
  extra=$(find "$destination" -mindepth 1 -maxdepth 1 ! -name SKILL.md ! -name .assistant-install.tsv ! -name .assistant-install.sha256 -print) || { _native_error failed "$destination"; return 1; }
  [[ -z "$extra" ]] || { _native_error extra "$destination"; return 1; }
}

# Check names in other folders too, including skills with additional native metadata.
_native_check_conflicts() {
  local root="$1" name="$2" destination file declared files
  destination="$root/$name"
  [[ ! -e "$destination" && ! -L "$destination" ]] || { _native_error conflict "$destination"; return 1; }
  [[ -d "$root" ]] || return 0
  files=$(find -L "$root" -mindepth 2 -maxdepth 2 -type f -name SKILL.md -print) || { _native_error failed "$root"; return 1; }
  while IFS= read -r file; do
    [[ -n "$file" ]] || continue
    declared=$(awk 'NR==1 { sub(/\r$/, ""); if ($0 != "---") exit; next }
      /^---\r?$/ { exit }
      /^name:[ \t]*/ { sub(/^name:[ \t]*/, ""); sub(/[ \t\r]+$/, ""); gsub(/^[\047\"]|[\047\"]$/, ""); print; exit }' "$file")
    [[ "$declared" != "$name" ]] || { _native_error conflict "$file"; return 1; }
  done <<< "$files"
}

_native_install() {
  local name="$1" harness="$2" scope="$3" root="$4" dry_run="$5" source_file="$6" renderer="$7"
  local destination="$root/$name" temp_dir source_hash installed_hash version run_rc
  _native_check_conflicts "$root" "$name" || return 1
  source_hash=$(_native_digest "$source_file") || return 1
  version=$(_native_source_version "$source_file") || return 1
  temp_dir=$(mktemp -d) || return 1
  if ! "$renderer" "$name" "$source_file" > "$temp_dir/SKILL.md"; then
    rm -rf -- "$temp_dir"
    return 1
  fi
  installed_hash=$(_native_digest "$temp_dir/SKILL.md") || { rm -rf -- "$temp_dir"; return 1; }
  {
    printf 'format\t1\nharness\t%s\nscope\t%s\nname\t%s\n' "$harness" "$scope" "$name"
    printf 'source\t%s\nsource_version\t%s\nsource_hash\t%s\ninstalled_hash\t%s\nrenderer\t1\n' "$source_file" "$version" "$source_hash" "$installed_hash"
  } > "$temp_dir/.assistant-install.tsv"
  _native_digest "$temp_dir/.assistant-install.tsv" > "$temp_dir/.assistant-install.sha256" || { rm -rf -- "$temp_dir"; return 1; }
  if [[ "$dry_run" == yes ]]; then
    t_native_plan install "$destination" "$source_file" "$version" "$installed_hash"
    rm -rf -- "$temp_dir"
    return 0
  fi
  # mkdir claims the target exclusively; an existing installation is never overwritten.
  if ! mkdir -p -- "$root" || ! mkdir -- "$destination"; then
    rm -rf -- "$temp_dir"
    _native_error conflict "$destination"
    return 1
  fi
  run_rc=0
  cp -- "$temp_dir/SKILL.md" "$temp_dir/.assistant-install.tsv" "$temp_dir/.assistant-install.sha256" "$destination/" || run_rc=1
  rm -rf -- "$temp_dir"
  if [[ $run_rc -eq 0 ]]; then
    _native_verify_files "$destination" "$name" "$harness" "$scope" || run_rc=1
  fi
  if [[ $run_rc -ne 0 ]]; then
    _native_error failed "$destination"
    return 1
  fi
  t_native_done install "$destination"
}

_cmd_skill_install() {
  local action="$1" name="${2:-}" harness="" scope="" project="" project_set=no dry_run=no
  [[ $# -ge 2 ]] || { t_native_usage; return 1; }
  shift 2
  [[ "$name" =~ ^[a-z0-9][a-z0-9_-]*$ ]] || { t_native_usage; return 1; }
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --harness|--scope|--project)
        [[ $# -ge 2 && -n "$2" && "$2" != --* ]] || { t_native_usage; return 1; }
        case "$1" in
          --harness) [[ -z "$harness" ]] || { t_native_usage; return 1; }; harness="$2" ;;
          --scope) [[ -z "$scope" ]] || { t_native_usage; return 1; }; scope="$2" ;;
          --project) [[ "$project_set" == no ]] || { t_native_usage; return 1; }; project="$2"; project_set=yes ;;
        esac
        shift 2
        ;;
      --dry-run) dry_run=yes; shift ;;
      *) t_native_usage; return 1 ;;
    esac
  done
  [[ -n "$harness" && ( "$scope" == project || "$scope" == user ) && ( "$scope" == project || "$project_set" == no ) && ( "$action" != verify || "$dry_run" == no ) ]] || { t_native_usage; return 1; }
  _harness_require "$harness" native_skills || return 1
  local clean_harness root_func renderer root destination source_file version
  clean_harness=$(_sanitize_engine_name "$harness")
  root_func="_engine_${clean_harness}_skill_root"
  renderer="_engine_${clean_harness}_render_skill"
  command -v "$root_func" >/dev/null 2>&1 && command -v "$renderer" >/dev/null 2>&1 || { _native_error unsupported "$harness"; return 1; }
  if [[ "$scope" == project ]]; then
    if [[ "$project_set" == no ]]; then
      project=$(git rev-parse --show-toplevel 2>/dev/null) || project="$PWD"
    fi
    project=$(cd -- "$project" && pwd -P) || { _native_error invalid "$project"; return 1; }
  fi
  root=$("$root_func" "$scope" "$project") || return 1
  [[ "$root" == /* && "$root" != *$'\t'* && "$root" != *$'\n'* ]] || { _native_error invalid "$root"; return 1; }
  _native_no_symlinks "$root" || return 1
  destination="$root/$name"
  case "$action" in
    install)
      _skill_is_reserved "$name" && { _native_error reserved "$name"; return 1; }
      source_file=$(_resolve_skill "$name") || { _native_error invalid "$name"; return 1; }
      [[ "$source_file" != *$'\t'* && "$source_file" != *$'\n'* ]] || { _native_error invalid "$source_file"; return 1; }
      _native_install "$name" "$harness" "$scope" "$root" "$dry_run" "$source_file" "$renderer"
      ;;
    verify|remove)
      _native_verify_files "$destination" "$name" "$harness" "$scope" || return 1
      if [[ "$action" == verify ]]; then
        t_native_done verify "$destination"
      elif [[ "$dry_run" == yes ]]; then
        version=$(_native_record_value "$destination/.assistant-install.tsv" source_version)
        t_native_plan remove "$destination" "$(_native_record_value "$destination/.assistant-install.tsv" source)" "$version" "$(_native_record_value "$destination/.assistant-install.tsv" installed_hash)"
      else
        rm -- "$destination/SKILL.md" "$destination/.assistant-install.tsv" "$destination/.assistant-install.sha256" && rmdir -- "$destination" || { _native_error failed "$destination"; return 1; }
        t_native_done remove "$destination"
      fi
      ;;
    *) t_native_usage; return 1 ;;
  esac
}
