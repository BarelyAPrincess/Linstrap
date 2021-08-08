#!/bin/bash

linux64 env -i -S USER=root HOME=/ TERM=xterm-256color LOGNAME=root LANG=C.UTF-8 XDF_RUNTIME_DIR=/ PATH=/System/XBinaries /usr/bin/unshare -m --root=. bash
