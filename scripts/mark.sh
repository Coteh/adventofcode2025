#!/bin/sh

ARG=$1

echo "$1" | grep -q "-"

if [ $? = 0 ]; then
    DAY=`echo $ARG | cut -d'-' -f1`
    DAY_NUM=$((10#$DAY))
    PART=`echo $ARG | cut -d'-' -f2`
    if [ "$PART" == "2" ]; then
        sed -i '' -E "/\|  $DAY_NUM/ s/^(.{11}✅)(.{7}).{2}(.*)$/\1\2✅\2/" README.md
    else
        sed -i '' -E "/\|  $DAY_NUM/ s/^(.{11}).{2}(.*)$/\1✅\2/" README.md
    fi
else
    DAY="$ARG"
    DAY_NUM=$((10#$DAY))

    sed -i '' -E "/\|  $DAY_NUM/ s/^(.{11}).{2}(.{7}).{2}(.*)$/\1✅\2✅\3/" README.md
fi
