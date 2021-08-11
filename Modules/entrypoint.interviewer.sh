# TODO Do a version check of base config. Maybe utilize a dummy git repository?
if [ -f "$LINSTRAP_CONFIG_DEFAULTS" ]; then
  PROMPT_DEFAULT="n"
  prompt_yes_no "A previous base configuration exists, it could be outdated. Would you like to update it?"
else
  PROMPT_RESULT="y"
fi

if [ "$PROMPT_RESULT" == "y" ]; then
  run_module entrypoint initconfig
  declare -p | grep -E "$INITCONF_PREFIX" | sed -E 's/^declare -- //g' > "$LINSTRAP_CONFIG_DEFAULTS"
else
  source "$LINSTRAP_CONFIG_DEFAULTS" || error "Failed to retrive the base configuration files."
fi

PROMPT_DEFAULT="c"
prompt_options_basic "Would you like to run the config interviewer now or accept the defaults?" i Interviewer d Defaults c Cancel
if [ "$PROMPT_RESULT" == "c" ]; then
  exit 0
elif [ "$PROMPT_RESULT" == "d" ] || [ "$PROMPT_RESULT" == "i" ]; then
  echo "Restoring defaults..."
  # TODO Restore defaults
fi

if [ "$PROMPT_RESULT" == "i" ]; then
  # TODO Read the interviewer questions one-by-one and prompt the user
fi