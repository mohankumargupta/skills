#!/usr/bin/env bash

#set -x

DATASHEET_URL="$1"

waybackurl() {
  local url=$1
	
  if [[ $url != *analog.com* ]]; then
    echo $url
  fi

  wayback=$(waybackpy --url "$DATASHEET_URL" --cdx 2>/dev/null) 
  #echo $wayback
  datasheet=$(echo $wayback | awk -v url="${DATASHEET_URL}" '$5=="200" {print "https://web.archive.org/web/" $2 "im_/" url}'| tail -n1) 
  echo $datasheet
}

newurl=$(waybackurl $DATASHEET_URL)
echo $newurl



