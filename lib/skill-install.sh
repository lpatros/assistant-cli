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

_native_verify_record() {
  local destination="$1" name="$2" harness="$3" scope="$4" record checksum expected actual
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
  [[ "$(_native_record_value "$record" source)" == /* ]] || { _native_error unmanaged "$record"; return 1; }
  [[ "$(_native_record_value "$record" source_hash)" =~ ^[a-f0-9]{64}$ && "$(_native_record_value "$record" installed_hash)" =~ ^[a-f0-9]{64}$ ]] || { _native_error unmanaged "$record"; return 1; }
}

_native_verify_files() {
  local destination="$1" name="$2" harness="$3" scope="$4" expected actual extra
  _native_verify_record "$destination" "$name" "$harness" "$scope" || return 1
  expected=$(_native_record_value "$destination/.assistant-install.tsv" installed_hash)
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
  local root="$1" name="$2" skip="${3:-}" destination file declared files
  destination="$root/$name"
  [[ "$destination" == "$skip" || ( ! -e "$destination" && ! -L "$destination" ) ]] || { _native_error conflict "$destination"; return 1; }
  [[ -d "$root" ]] || return 0
  files=$(find -L "$root" -mindepth 2 -maxdepth 2 -type f -name SKILL.md -print) || { _native_error failed "$root"; return 1; }
  while IFS= read -r file; do
    [[ -n "$file" && "$file" != "$skip/SKILL.md" ]] || continue
    declared=$(awk 'NR==1 { sub(/\r$/, ""); if ($0 != "---") exit; next }
      /^---\r?$/ { exit }
      /^name:[ \t]*/ { sub(/^name:[ \t]*/, ""); sub(/[ \t\r]+$/, ""); gsub(/^[\047\"]|[\047\"]$/, ""); print; exit }' "$file")
    [[ "$declared" != "$name" ]] || { _native_error conflict "$file"; return 1; }
  done <<< "$files"
}

_native_build_package() {
  local name="$1" harness="$2" scope="$3" source_file="$4" renderer="$5" temp_dir="$6"
  local source_hash installed_hash version metadata
  _native_no_symlinks "$source_file" || return 1
  metadata=$(_skill_metadata "$source_file") || { _native_error invalid "$source_file"; return 1; }
  [[ "${metadata%%$'\t'*}" == "$name" ]] || { _native_error invalid "$source_file"; return 1; }
  source_hash=$(_native_digest "$source_file") || return 1
  version=$(_native_source_version "$source_file") || return 1
  if ! "$renderer" "$name" "$source_file" > "$temp_dir/SKILL.md"; then
    return 1
  fi
  [[ "$source_hash" == "$(_native_digest "$source_file")" ]] || { _native_error source_changed "$source_file"; return 1; }
  installed_hash=$(_native_digest "$temp_dir/SKILL.md") || return 1
  {
    printf 'format\t1\nharness\t%s\nscope\t%s\nname\t%s\n' "$harness" "$scope" "$name"
    printf 'source\t%s\nsource_version\t%s\nsource_hash\t%s\ninstalled_hash\t%s\nrenderer\t1\n' "$source_file" "$version" "$source_hash" "$installed_hash"
  } > "$temp_dir/.assistant-install.tsv" || return 1
  _native_digest "$temp_dir/.assistant-install.tsv" > "$temp_dir/.assistant-install.sha256" || return 1
  _native_verify_files "$temp_dir" "$name" "$harness" "$scope"
}

_native_install() {
  local name="$1" harness="$2" scope="$3" root="$4" dry_run="$5" source_file="$6" renderer="$7"
  local destination="$root/$name" temp_dir installed_hash version run_rc
  _native_check_conflicts "$root" "$name" || return 1
  temp_dir=$(mktemp -d) || return 1
  _native_build_package "$name" "$harness" "$scope" "$source_file" "$renderer" "$temp_dir" || { rm -rf -- "$temp_dir"; return 1; }
  installed_hash=$(_native_record_value "$temp_dir/.assistant-install.tsv" installed_hash)
  version=$(_native_record_value "$temp_dir/.assistant-install.tsv" source_version)
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
