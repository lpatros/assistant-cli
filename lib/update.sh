_cmd_update() {
  t_update_starting
  
  if git -C "$ASSISTANT_ROOT_DIR" pull; then
    t_update_success
  else
    t_update_failed
    return 1
  fi
}
