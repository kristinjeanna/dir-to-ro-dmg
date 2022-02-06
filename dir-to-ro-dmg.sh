#!/bin/bash

EXPECTED_ARGS=3

if [ $# -ne $EXPECTED_ARGS ]; then
  echo "Incorrect args: $#"
  echo "Usage: $0 {dir to archive} {volume name} {volume filename}"
  for var in "$@"; do
    echo $var
  done
  exit 1
fi

# size of directory in MB
SIZE=`du -BM -s $1 | awk '{print $1}' | sed -e 's/M//'`
SIZE=$((SIZE*2))

# create the read-write filesystem
hdiutil create -megabytes ${SIZE} -type SPARSE -fs HFS+J -volname $2 $3

# attach it
hdiutil attach $3.sparseimage

# copy content to it
/bin/cp -R $1 /Volumes/$2/

# detach it
DEVICE=`mount | grep $2 | awk '{print $1}'`
hdiutil detach ${DEVICE}

# compact it (which may or may not have much effect)
hdiutil compact $3.sparseimage -batteryallowed

# convert RW sparseimage to RO image
hdiutil convert $3.sparseimage -format UDRO -o $3
rm $3.sparseimage
