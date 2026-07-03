echo "BASH_SOURCE: ${BASH_SOURCE[0]:-}"
echo "ZSH_VERSION: ${ZSH_VERSION:-}"
if [ -n "${BASH_SOURCE[0]:-}" ]; then
  echo "using BASH_SOURCE"
  _dir="$(dirname -- "${BASH_SOURCE[0]}")"
elif [ -n "${ZSH_VERSION:-}" ]; then
  echo "using ZSH_VERSION"
  _dir="$(dirname -- "${(%):-%x}")"
else
  echo "using \$0"
  _dir="$(dirname -- "$0")"
fi
echo "$_dir"
