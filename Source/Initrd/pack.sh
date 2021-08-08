#!/bin/bash

bash -c "find * | grep -Ev \"^(proc|dev|sys)\" | tee | cpio --create -H newc" | gzip -9 > ../initrd.img-linstrap
