PROMPT_DEFAULT="n"
if prompt_yes_no "This function will delete all configuration and build files from the workspace. Do you wish to continue?"; then
    echo -n "Cleaning workspace..."
    
    [ -f "$LINSTRAP_CONFIG_VALUES" ] && rm $LINSTRAP_CONFIG_VALUES
    [ -f "$LINSTRAP_CONFIG_DEFAULTS" ] && rm $LINSTRAP_CONFIG_DEFAULTS

    echo "complete!"
fi
