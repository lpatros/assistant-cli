_is_installed() {
  local cmd="${1:-}"
  [[ -n "$cmd" ]] && command -v "$cmd" &>/dev/null
}

_get_indirect_var() {
  local _src_var="$1"
  local _dst_var="$2"
  if [[ -n "${ZSH_VERSION:-}" ]]; then
    eval "${_dst_var}=\"\${(P)_src_var:-}\""
  else
    eval "${_dst_var}=\"\${!_src_var:-}\""
  fi
}


_prompt_read() {
  local var_name="$1"
  if [ -c /dev/tty ]; then
    read -r "$var_name" </dev/tty || true
  else
    read -r "$var_name" || true
  fi
}

_info()    { echo -e "${CYAN}ℹ${RESET}  $*"; }
_success() { echo -e "${GREEN}✓${RESET}  $*"; }
_warn()    { echo -e "${YELLOW}⚠${RESET}  $*"; }
_error()   { echo -e "${RED}✗${RESET}  $*"; }
_header()  { echo -e "\n${BOLD}${BLUE}$*${RESET}\n"; }

_model_display() {
  if [[ -z "$1" ]]; then
    t_default_engine_model
    return 0
  fi
  echo "$1"
}

_read_guidelines() {
  local filepath="$1"
  if [[ ! -f "$filepath" ]]; then
    t_convention_file_not_found "$filepath"
    t_continuing_without_guidelines
    echo ""
    return 0
  fi
  awk '{ sub(/\r$/, "") }
    NR == 1 && $0 == "---" { header = 1; next }
    header && $0 == "---" { header = 0; next }
    !header { print }' "$filepath"
}

_get_skill_md_path() {
  _resolve_skill "$1"
}

_get_changelog_file() {
  local channel=""
  if command -v "_get_current_channel" &>/dev/null; then
    channel="$(_get_current_channel)"
  fi

  if [[ "$channel" == "beta" ]]; then
    if [[ -f "$ASSISTANT_ROOT_DIR/CHANGELOG-beta.md" ]]; then
      echo "$ASSISTANT_ROOT_DIR/CHANGELOG-beta.md"
      return 0
    fi
  fi

  if [[ -f "$ASSISTANT_ROOT_DIR/CHANGELOG.md" ]]; then
    echo "$ASSISTANT_ROOT_DIR/CHANGELOG.md"
    return 0
  fi
}

_get_repo_url() {
  local remote_url=""
  if _is_installed "git" && [[ -d "$ASSISTANT_ROOT_DIR/.git" ]]; then
    remote_url="$(git -C "$ASSISTANT_ROOT_DIR" remote get-url origin 2>/dev/null || true)"
  fi
  if [[ -n "$remote_url" ]]; then
    remote_url="$(echo "$remote_url" | sed -E 's|^git@github\.com:|https://github.com/|; s|\.git$||')"
    echo "$remote_url"
  else
    echo "https://github.com/lpatros/assistant-cli"
  fi
}

_get_release_url() {
  local repo_url version tag_url
  repo_url="$(_get_repo_url)"
  if command -v "_get_assistant_version" &>/dev/null; then
    version="$(_get_assistant_version 2>/dev/null || true)"
  fi

  if [[ -n "$version" && "$version" != "unknown" ]]; then
    tag_url="${repo_url}/releases/tag/v${version#v}"
    echo "$tag_url"
  else
    echo "${repo_url}/releases"
  fi
}

_open_url() {
  local url="${1:-}"
  [[ -z "$url" ]] && return 1

  if _is_installed "xdg-open"; then
    ( xdg-open "$url" &>/dev/null & ) &>/dev/null
  elif _is_installed "open"; then
    ( open "$url" &>/dev/null & ) &>/dev/null
  elif _is_installed "wslview"; then
    ( wslview "$url" &>/dev/null & ) &>/dev/null
  elif _is_installed "cmd.exe"; then
    ( cmd.exe /c start "$url" &>/dev/null & ) &>/dev/null
  else
    return 1
  fi
  return 0
}

_format_table() {
  printf '%s\n' "$1" | LC_ALL=C awk -F '\t' -v max_width="${2:-0}" -v shorten="${3:-}" '
    # Count UTF-8 characters without depending on the awk implementation or locale.
    function characters(value) {
      gsub(/[\200-\277]/, "", value)
      return length(value)
    }
    function take(value, count, byte, size) {
      size = 0
      for (byte = 1; byte <= length(value); byte++) {
        if (substr(value, byte, 1) !~ /[\200-\277]/) {
          if (size == count) break
          size++
        }
      }
      return substr(value, 1, byte - 1)
    }
    function abbreviate(value, width, head, tail, skip, parts, count, prefix, suffix, candidate) {
      if (characters(value) <= width) return value
      if (width <= 3) return substr("...", 1, width)
      count = split(value, parts, "/")
      if (count > 3 && substr(value, 1, 1) == "/") {
        prefix = "/" parts[2] "/" parts[3]
        suffix = parts[count - 1] "/" parts[count]
        candidate = prefix "/.../" suffix
        if (characters(candidate) <= width) return candidate
        candidate = "/" parts[2] "/.../" suffix
        if (characters(candidate) <= width) return candidate
        candidate = "/.../" suffix
        if (characters(candidate) <= width) return candidate
        candidate = "/" parts[2] "/.../" parts[count]
        if (characters(candidate) <= width) return candidate
        candidate = "/.../" parts[count]
        if (characters(candidate) <= width) return candidate
      }
      head = int((width - 3) / 2)
      tail = width - head - 3
      skip = take(value, characters(value) - tail)
      return take(value, head) "..." substr(value, length(skip) + 1)
    }
    BEGIN {
      count = split(shorten, selected, " ")
      for (i = 1; i <= count; i++) compact[selected[i]] = 1
    }
    {
      for (column = 1; column <= NF; column++) {
        cells[NR, column] = $column
        size = characters($column)
        if (NR > 1 && compact[column] && size > 32) size = 32
        if (size > widths[column]) widths[column] = size
      }
      columns = NF
    }
    END {
      total = 3 * (columns - 1)
      for (column = 1; column <= columns; column++) total += widths[column]
      if (max_width >= 3 * (columns - 1) + columns) {
        while (total > max_width) {
          widest = 1
          for (column = 2; column <= columns; column++) {
            if (widths[column] > widths[widest]) widest = column
          }
          widths[widest]--
          total--
        }
      }
      for (row = 1; row <= NR; row++) {
        for (column = 1; column <= columns; column++) {
          remaining[column] = cells[row, column]
          if (row > 1 && compact[column]) remaining[column] = abbreviate(remaining[column], widths[column])
        }
        more = 1
        while (more) {
          more = 0
          for (column = 1; column <= columns; column++) {
            value = take(remaining[column], widths[column])
            # Wrap labels at spaces when possible; long names retain every character.
            if (characters(remaining[column]) > widths[column] && index(value, " ")) {
              sub(/ [^ ]*$/, "", value)
            }
            remaining[column] = substr(remaining[column], length(value) + 1)
            sub(/^ +/, "", remaining[column])
            sub(/ +$/, "", value)
            if (remaining[column] != "") more = 1
            printf "%s", value
            if (column < columns) printf "%*s | ", widths[column] - characters(value), ""
          }
          printf "\n"
        }
        if (row == 1) {
          for (column = 1; column <= columns; column++) {
            for (dash = 0; dash < widths[column]; dash++) printf "-"
            printf "%s", (column < columns ? "-+-" : "\n")
          }
        }
      }
    }'
}

