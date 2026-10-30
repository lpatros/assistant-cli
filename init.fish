# init.fish — fish entry point for Assistant CLI.
#
# fish cannot source bash scripts, so this file defines the `assistant`
# function in fish syntax and delegates every call to init.sh running in
# a bash subshell. All logic stays in bash; keep this file a thin wrapper
# and keep it fish-parseable (`fish -n init.fish`).

# Repo root, resolved while this file is being sourced (status filename
# points at the sourced file). The function below closes over this value.
set -l _assistant_root (dirname (status filename))

function assistant --description 'Assistant CLI - LLM command-line wrapper'
    bash -c 'source "$1/init.sh" && shift && assistant "$@"' assistant "$_assistant_root" $argv
end

complete -c assistant -f
complete -c assistant -f -a 'skills commit branch create resume readme model engine think lang custom status update channel changelog version help --version --help --think --no-think --hide-think'

complete -c assistant -n "__fish_seen_subcommand_from skills" -a list
