# Incomplete

for LOC in $(ls ${LINSTRAP_HOME}/scripts/chroot-pre-* 2>/dev/null); do
    test -f "$LOC" && source $LOC
done

## Add message that if the init system fails to launch, the suggestion to use git to reset can be presented.

echo "Everything checks out! Now launching Linstrap chroot located at \"${LINSTRAP_DATA}\"..."
echo
$CHROOT "${LINSTRAP_DATA}" $1

for LOC in $(ls ${LINSTRAP_HOME}/scripts/chroot-post-* 2>/dev/null); do
    test -f "$LOC" && source $LOC
done










if [ -n "$BUILD_DIR" ]; then
    BUILD_DIR=$(dirname $0)
    BUILD_DIR=$(realpath $BUILD_DIR)
fi

[ -e "$BUILD_DIR/.env" ] && source "$BUILD_DIR/.env"

# [ -n "$INITRD_DIR" ] && INITRD_DIR="$BUILD_DIR/initrd"
# [ -n "$KERNEL_DIR" ] && KERNEL_DIR="$BUILD_DIR/kernel"
[ -n "$OUTPUT_DIR" ] && OUTPUT_DIR="$BUILD_DIR/output"

PID_FILE="$BUILD_DIR/$PRODUCT.pid"
CHARDEV="$BUILD_DIR/$PRODUCT"

mkfifo "$CHARDEV.in" 2>/dev/null
mkfifo "$CHARDEV.out" 2>/dev/null

if [ -f "$PID_FILE" ]; then
	if ps -p `cat linstrap.pid` > /dev/null; then
		echo "Detected QEMU already running... terminating."
		timeout 6 echo "quit" > "$CHARDEV.in"
		if [ -f "$PID_FILE" ]; then
			kill -9 $(cat linstrap.pid)
			sleep 1
		fi
	fi
	rm "$PID_FILE"
fi

echo -n "Looking for latest kernel file... "

# Find latest kernel
KERNEL=""
for FILE in $(ls "$OUTPUT_DIR" | sort); do
	[[ "$(file "$OUTPUT_DIR/$FILE")" =~ bzImage ]] && KERNEL="$OUTPUT_DIR/$FILE"
done

if [ ! -n "$KERNEL" ]; then
	echo "ERROR: We could not find any valid kernel!"
	exit 1
fi

echo "Found kernel file: $KERNEL"

qemu-system-x86_64 \
	-pidfile "$PID_FILE" \
	-chardev pipe,id=$PRODUCT,path=$CHARDEV \
	-daemonize \
	-mon $PRODUCT \
	-serial pty \
	-vnc 0.0.0.0:1 -k en-us \
	-enable-kvm \
	-m 8192 \
	-smp 2 \
	-cpu host \
	-boot menu=on \
	-net nic \
	-net user,hostfwd=tcp::5555-:22 \
	-kernel "$KERNEL" \
	-append "DEBUG=2" \
	-initrd $BUILD_DIR/output/initrd.img-linstrap \
	"$@"
