# Retain text from the last assistant step, excluding tools and reasoning.
# OpenCode can omit the last step_finish, so rely on the CLI exit code too.
reduce .[] as $event ({text: [], message: null};
  if $event.type == "error" then error($event | tostring)
  elif $event.type == "step_start" then {text: [], message: null}
  elif $event.type == "text" and ($event.part.text | type) == "string" then
    ($event.part.messageID // null) as $message |
    if .message != null and $message != .message then
      {text: [$event.part.text], message: $message}
    else .text += [$event.part.text] | .message = $message end
  else . end
) | .text | join("\n") | select(length > 0)
