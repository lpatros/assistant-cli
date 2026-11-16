_native_declared_name() {
  awk 'NR==1 { sub(/\r$/, ""); if ($0 != "---") exit; next }
    /^---\r?$/ { exit }
    /^name:[ \t]*/ { sub(/^name:[ \t]*/, ""); sub(/[ \t\r]+$/, ""); gsub(/^[\047\"]|[\047\"]$/, ""); print; exit }' "$1"
}

_native_skill_files() {
  [[ -d "$1" ]] || return 0
  local files
  files=$(find -L "$1" -mindepth 2 -maxdepth 2 -type f -name SKILL.md -print) || return 1
  [[ -z "$files" ]] || printf '%s\n' "$files" | LC_ALL=C sort
}

_native_inventory_files() {
  [[ -d "$1" ]] || return 0
  local files
  files=$(find -L "$1" -mindepth 2 -maxdepth 2 -type f \( -name SKILL.md -o -name .assistant-install.tsv \) -print) || return 1
  [[ -z "$files" ]] || printf '%s\n' "$files" | sed 's@/[^/]*$@/SKILL.md@' | LC_ALL=C sort -u
}

_native_discovery_roots() {
  local harness="$1" context="$2" hook roots project_root user_root
  hook="_engine_$(_sanitize_engine_name "$harness")_skill_roots"
  if command -v "$hook" >/dev/null 2>&1; then
    roots=$("$hook" "$context") || return 1
  else
    hook="_engine_$(_sanitize_engine_name "$harness")_skill_root"
    project_root=$("$hook" project "$context") || return 1
    user_root=$("$hook" user '') || return 1
    roots=$(printf 'project\t%s\nuser\t%s\n' "$project_root" "$user_root")
  fi
  printf '%s\n' "$roots" | awk -F '\t' 'NF != 2 || $1 !~ /^(project|ancestor|user)$/ || $2 !~ /^\// { bad=1; next } !seen[$2]++ { print } END { if (bad) exit 1 }'
}

_native_cross_scope_notice() {
  local roots="$1" name="$2" target="$3" scope root file declared files
  while IFS=$'\t' read -r scope root; do
    [[ -n "$root" && "$root" != "$target" ]] || continue
    files=$(_native_skill_files "$root") || return 1
    while IFS= read -r file; do
      [[ -n "$file" ]] || continue
      declared=$(_native_declared_name "$file") || return 1
      [[ "$declared" != "$name" ]] || t_native_duplicate "$name" "$file" >&2
    done <<< "$files"
  done <<< "$roots"
}

# Data columns: name, scope, root, destination. Unknown packages remain visible.
_native_inventory_entries() {
  local roots="$1" requested="$2" scope root files file name destination
  while IFS=$'\t' read -r scope root; do
    [[ -n "$root" ]] || continue
    files=$(_native_inventory_files "$root") || return 1
    while IFS= read -r file; do
      [[ -n "$file" ]] || continue
      [[ "$file" != *$'\t'* ]] || { _native_error invalid "$file"; return 1; }
      destination=$(dirname -- "$file")
      name=""
      [[ ! -f "$file" ]] || name=$(_native_declared_name "$file") || return 1
      [[ "$name" =~ ^[a-z0-9][a-z0-9_-]*$ ]] || name=$(basename -- "$destination")
      [[ -z "$requested" || "$requested" == "$name" || "$requested" == "$(basename -- "$destination")" ]] || continue
      printf '%s\t%s\t%s\t%s\n' "$name" "$scope" "$root" "$destination"
    done <<< "$files"
  done <<< "$roots"
}

_native_inventory_row() {
  local name="$1" scope="$2" root="$3" destination="$4" harness="$5" expected_scope="$2"
  local source_file=- revision=- edits=unmanaged available=unknown backup_state=no backup record current_hash metadata
  [[ "$scope" != ancestor ]] || expected_scope=project
  record="$destination/.assistant-install.tsv"
  if [[ -e "$record" || -L "$record" ]]; then
    edits=invalid
    if _native_verify_record "$destination" "$name" "$harness" "$expected_scope" >/dev/null 2>&1; then
      source_file=$(_native_record_value "$record" source)
      revision=$(_native_record_value "$record" source_version)
      if [[ "$revision" =~ ^[a-f0-9]{40,64}(:modified)?$ ]]; then
        local suffix=""
        [[ "$revision" != *:modified ]] || suffix=:modified
        revision="${revision:0:12}$suffix"
      fi
      edits=no
      _native_verify_files "$destination" "$name" "$harness" "$expected_scope" >/dev/null 2>&1 || edits=yes
      if [[ ! -f "$source_file" ]]; then
        available=missing
      else
        available=source_invalid
        metadata=$(_skill_metadata "$source_file" 2>/dev/null)
        if [[ "$?" -eq 0 && "${metadata%%$'\t'*}" == "$name" ]] && _native_no_symlinks "$source_file" >/dev/null 2>&1; then
          current_hash=$(_native_digest "$source_file") || return 1
          available=no
          [[ "$current_hash" == "$(_native_record_value "$record" source_hash)" ]] || available=yes
        fi
        if [[ -n "${NATIVE_INSPECT_NAME:-}" ]]; then _native_source_notice "$name" "$source_file"; fi
      fi
    fi
  fi
  backup=$(_native_backup_path "$root" "$harness" "$(basename -- "$destination")")
  if [[ -e "$backup" || -L "$backup" ]]; then
    backup_state=invalid
    _native_verify_files "$backup" "$name" "$harness" "$expected_scope" >/dev/null 2>&1 && backup_state=yes
  fi
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$name" "$(t_native_scope "$scope")" "$source_file" "$revision" "$(t_native_state "$edits")" "$(t_native_state "$available")" "$(t_native_state "$backup_state")" "$destination"
}

_native_inventory_table() {
  local table="$1" width="$2" summary paths
  if [[ "$width" -ge 160 ]]; then
    _format_table "$table" "$width" '3 8'
  else
    summary=$(printf '%s\n' "$table" | awk -F '\t' 'BEGIN { OFS=FS } { print $1,$2,$4,$5,$6,$7 }')
    paths=$(printf '%s\n' "$table" | awk -F '\t' 'BEGIN { OFS=FS } { print $1,$3,$8 }')
    _format_table "$summary" "$width" || return 1
    printf '\n'
    _format_table "$paths" "$width" '2 3'
  fi
}

_native_inventory() {
  local roots="$1" requested="$2" harness="$3" filter="$4" action="$5" entries visible table name scope root destination result=0 duplicates
  # Dynamically scoped so individual status requests can explain source overrides.
  local NATIVE_INSPECT_NAME="$requested"
  entries=$(_native_inventory_entries "$roots" "$requested") || return 1
  visible=$(printf '%s\n' "$entries" | awk -F '\t' -v scope="$filter" 'NF == 4 && (scope == "all" || scope == $2 || (scope == "project" && $2 == "ancestor"))')
  if [[ -n "$requested" && -z "$visible" ]]; then _native_error not_installed "$requested"; return 1; fi
  table=$(
    t_native_inventory_header
    while IFS=$'\t' read -r name scope root destination; do
      [[ -n "$name" ]] || continue
      [[ "$filter" == all || "$filter" == "$scope" || ( "$filter" == project && "$scope" == ancestor ) ]] || continue
      _native_inventory_row "$name" "$scope" "$root" "$destination" "$harness" || return 1
    done <<< "$visible"
  ) || return 1
  local terminal_width="${COLUMNS:-160}"
  [[ "$terminal_width" =~ ^[0-9]+$ && "$terminal_width" -ge 40 && "$terminal_width" -le 10000 ]] || terminal_width=160
  _native_inventory_table "$table" "$terminal_width" || return 1
  if [[ "$action" == status && -n "$requested" ]]; then
    local record source_file revision current_version current_hash expected_scope
    while IFS=$'\t' read -r name scope root destination; do
      [[ -n "$name" ]] || continue
      expected_scope="$scope"
      [[ "$scope" != ancestor ]] || expected_scope=project
      if ! _native_verify_record "$destination" "$name" "$harness" "$expected_scope" >/dev/null 2>&1; then
        t_native_versions "$destination" - - - - -
        continue
      fi
      record="$destination/.assistant-install.tsv"
      source_file=$(_native_record_value "$record" source)
      revision=$(_native_record_value "$record" source_version)
      current_version=-
      current_hash=-
      if [[ -f "$source_file" ]] && _native_no_symlinks "$source_file" >/dev/null 2>&1; then
        current_version=$(_native_source_version "$source_file") || return 1
        current_hash=$(_native_digest "$source_file") || return 1
      fi
      t_native_versions "$destination" "$revision" "$current_version" "$(_native_record_value "$record" source_hash)" "$current_hash" "$source_file"
    done <<< "$visible"
  fi
  duplicates=$(printf '%s\n' "$entries" | awk -F '\t' 'NF == 4 { rows[NR]=$0; names[$1]++; localnames[$1 SUBSEP $3]++ }
    END { for (i=1; i<=NR; i++) { split(rows[i],r,FS); if (names[r[1]] > 1) print rows[i] "\t" (localnames[r[1] SUBSEP r[3]] > 1 ? "conflict" : "warning") } }')
  local level
  while IFS=$'\t' read -r name scope root destination level; do
    [[ -n "$name" ]] || continue
    t_native_duplicate "$name" "$destination/SKILL.md" >&2
    if [[ "$level" == conflict && ( "$filter" == all || "$filter" == "$scope" || ( "$filter" == project && "$scope" == ancestor ) ) ]]; then result=1; fi
  done <<< "$duplicates"
  return "$result"
}
