#!/usr/bin/env bash

#set -x

DATASHEET_URL="$1"

if [[ $DATASHEET_URL != *analog.com* ]]; then
  echo $DATASHEET_URL
  exit 0
fi

wayback=$(waybackpy --url "$DATASHEET_URL" --cdx 2>/dev/null) 
echo $wayback
datasheet=$(echo $wayback | awk -v url="${DATASHEET_URL}" '$5=="200" {print "https://web.archive.org/web/" $2 "im_/" url}'| tail -n1) 
echo $datasheet
