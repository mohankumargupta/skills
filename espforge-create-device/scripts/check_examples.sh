#!/usr/bin/env bash
#set -x 
# Usage: ./check_examples.sh owner/repo device
GH_REPO="$1"
#OWNER="${GH_REPO%%/*}"
REPOSITORY="${GH_REPO#*/}"

if [ -z "$REPOSITORY" ]; then
    echo "Usage: $0 owner/repo"
    exit 1
fi

RESULT=$(curl -s -o /dev/null -w "%{http_code}" "https://api.github.com/repos/$GH_REPO/contents/examples")

if [ "$RESULT" == "200" ];
then
  mkdir -p "artifacts/$REPOSITORY/examples"
  npx -y tiged --force "${GH_REPO}/examples" "artifacts/$REPOSITORY/examples" || exit 1
else
exit 1
fi
