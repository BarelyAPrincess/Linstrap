source $LINSTRAP_ROOT/entrypoint.functions.sh || error "Could not include the entrypoint.helper.sh file."
source $LINSTRAP_ROOT/entrypoint.env.sh || error "Could not include the entrypoint.env.sh file."
source $LINSTRAP_ROOT/entrypoint.header.sh || error "Could not include the entrypoint.header.sh file."

[ "$(type -t show_header)" == "function" ] && show_header # Check that the function was created

echo "Checking Linstrap Environment..."

# Check for critical files
checkdir_or_fail MODULES Modules # Contains modules scripts for checking and building
