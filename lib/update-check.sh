UPDATE_CHECK_TTL="${UPDATE_CHECK_TTL:-86400}"

_update_check_cache_file() {
  echo "$ASSISTANT_ROOT_DIR/data/update-check.txt"
}

_version_max() {
  awk '
    function parse(v, core, pre,   i) {
      i = index(v, "-")
      if (i > 0) {
        core[1] = substr(v, 1, i - 1)
        pre[1] = substr(v, i + 1)
      } else {
        core[1] = v
        pre[1] = ""
      }
    }
    function gt(a, b,   ac, ap, bc, bp, AN, BN, i, av, bv, AP, BP, k, x, y, n, m) {
      split("", ac); split("", ap); split("", bc); split("", bp)
      parse(a, ac, ap); parse(b, bc, bp)
      split(ac[1], AN, "."); split(bc[1], BN, ".")
      for (i = 1; i <= 3; i++) {
        av = (i in AN) ? AN[i] + 0 : 0
        bv = (i in BN) ? BN[i] + 0 : 0
        if (av > bv) return 1
        if (av < bv) return 0
      }
      if (ap[1] == "" && bp[1] == "") return 0
      if (ap[1] == "") return 1
      if (bp[1] == "") return 0
      split(ap[1], AP, "."); split(bp[1], BP, ".")
      n = 0; for (k in AP) if (k + 0 > n) n = k + 0
      m = 0; for (k in BP) if (k + 0 > m) m = k + 0
      for (i = 1; i <= ((n > m) ? n : m); i++) {
        x = (i in AP) ? AP[i] : ""
        y = (i in BP) ? BP[i] : ""
        if (x ~ /^[0-9]+$/ && y ~ /^[0-9]+$/) {
          if (x + 0 > y + 0) return 1
          if (x + 0 < y + 0) return 0
        } else {
          if (x > y) return 1
          if (x < y) return 0
        }
      }
      return 0
    }
    NF {
      if (max == "" || gt($0, max)) max = $0
    }
    END { if (max != "") print max }
  '
}

_update_check_is_newer() {
  local remote="$1"
  local current="$2"
  [[ -z "$remote" || -z "$current" || "$current" == "unknown" ]] && return 1
  [[ "$remote" == "$current" ]] && return 1
  local max
  max="$(printf '%s\n%s\n' "$current" "$remote" | _version_max)"
  [[ "$max" == "$remote" ]]
}

_update_check_refresh() {
  local cache="$1"
  local checked_at="$2"
  local current remote notified_v=""

  current="$(_get_assistant_version 2>/dev/null || true)"

  remote="$(GIT_TERMINAL_PROMPT=0 git -C "$ASSISTANT_ROOT_DIR" ls-remote --tags --refs origin 2>/dev/null \
    | awk -F/ '{print $NF}' \
    | sed 's/^v//' \
    | grep -E '^[0-9]+\.[0-9]+\.[0-9]+([.+-][0-9A-Za-z.+-]+)?$' \
    | { if [[ "$current" == *-* ]]; then cat; else grep -v -- '-'; fi; } \
    | _version_max)"

  if [[ -n "$remote" ]]; then
    if [[ -f "$cache" ]]; then
      IFS='|' read -r _ _ notified_v < "$cache" || true
    fi
    mkdir -p "$(dirname "$cache")"
    printf '%s|%s|%s\n' "$checked_at" "$remote" "${notified_v:-}" > "$cache.tmp" \
      && mv "$cache.tmp" "$cache"
  fi
}

_update_check_start() {
  [[ -n "${ASSISTANT_NO_UPDATE_CHECK:-}" ]] && return 0
  _is_installed "git" || return 0
  [[ -d "$ASSISTANT_ROOT_DIR/.git" ]] || return 0

  local cache now checked remote notified
  cache="$(_update_check_cache_file)"
  now="$(date +%s)"
  checked=""
  remote=""
  notified=""

  if [[ -f "$cache" ]]; then
    IFS='|' read -r checked remote notified < "$cache" || true
    if [[ "$checked" =~ ^[0-9]+$ ]] && (( now - checked < UPDATE_CHECK_TTL )); then
      return 0
    fi
  fi

  ( ( _update_check_refresh "$cache" "$now" </dev/null >/dev/null 2>&1 & ) ) >/dev/null 2>&1
}

_update_check_notify() {
  [[ -n "${ASSISTANT_NO_UPDATE_CHECK:-}" ]] && return 0

  local cache checked remote notified current
  cache="$(_update_check_cache_file)"
  [[ -f "$cache" ]] || return 0

  checked=""
  remote=""
  notified=""
  IFS='|' read -r checked remote notified < "$cache" || return 0
  [[ -n "$remote" ]] || return 0

  current="$(_get_assistant_version 2>/dev/null || true)"
  _update_check_is_newer "$remote" "$current" || return 0
  [[ "$notified" == "$remote" ]] && return 0

  t_update_available "$remote" "$current"

  if [[ "$checked" =~ ^[0-9]+$ ]]; then
    printf '%s|%s|%s\n' "$checked" "$remote" "$remote" > "$cache.tmp" \
      && mv "$cache.tmp" "$cache"
  fi
}
