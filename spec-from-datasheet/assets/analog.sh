#!/usr/bin/env bash

#set -x

DATASHEET_URL="https://www.analog.com/media/en/technical-documentation/data-sheets/max6675.pdf" 
wayback=$(waybackpy --url "$DATASHEET_URL" --cdx 2>/dev/null) 

datasheet=$(echo $wayback | awk -v url="${DATASHEET_URL}" '$5=="200" {print "https://web.archive.org/web/" $2 "/" url}'| head -n1) 
echo $datasheet
