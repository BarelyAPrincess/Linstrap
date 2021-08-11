# bash -c "cd $LINSTRAP_SOURCE_KERNEL && INSTALL_PATH=$LINSTRAP_BUILD_BOOT make install && INSTALL_MOD_PATH=$LINSTRAP_BUILD_INITRD make modules_install"

bash -c "cd $LINSTRAP_SOURCE_INITRD && find * | grep -Ev \"^(proc|dev|sys)\" | tee | cpio --create -H newc" | gzip -9 > "$LINSTRAP_BUILD_BOOT/initrd.img-linstrap"
