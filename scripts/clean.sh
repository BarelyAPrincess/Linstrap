#!/bin/bash

source "`dirname $0`/bin/functions"

printf "Clearing Work Directory..."
rm -r workdir/*
echo "done!"

printf "Deleting Debootstrap Binary"
rm -r bin/debootstrap
echo "done!"
