#!/bin/bash

GIT_DIR=$(dirname -- "$( readlink -f -- "$0"; )")

mkdir -p /tmp/test
cd /tmp/test || exit
rm -rf /tmp/test/*
# mkdir updated_json
mkdir original_json
mkdir -p "$GIT_DIR/mc/game"
mkdir -p "$GIT_DIR/mc-static-json"
mkdir -p "$GIT_DIR/version-json"

# mkdir original_json_jq

wget https://piston-meta.mojang.com/mc/game/version_manifest_v2.json || exit 1
cat version_manifest_v2.json | jq -r '.versions[].url' > urls.txt

cd original_json
wget --retry-on-http-error=500 --waitretry=1 -i ../urls.txt || exit 0

cp ../version_manifest_v2.json "$GIT_DIR/mc/game/version_manifest_v2_noncompact.json"

spruce(){
  "$GIT_DIR/spruce-linux-amd64" "$@"
}

OIFS="$IFS"
IFS=$'\n'
for json_file in `find . -type f -name "*.json"`; do
  # cat "$json_file" | jq > "../original_json_jq/$json_file"
  
  # "name": "org.lwjgl:lwjgl:3.3.1"
  lwjgl_version=$(cat "$json_file" | jq -r '.libraries | .[] | .name | select(contains("org.lwjgl:lwjgl:"))' | sed 's/org.lwjgl:lwjgl://g' | sed '/:/d' | sort -g -r | head -1)
  if [ -z "$lwjgl_version" ];then
    # "name": "org.lwjgl.lwjgl:lwjgl:2.9.1-nightly-20131120"
    lwjgl_version=$(cat "$json_file" | jq -r '.libraries | .[] | .name | select(contains("org.lwjgl.lwjgl:lwjgl:"))' | sed 's/org.lwjgl.lwjgl:lwjgl://g' | sed '/:/d' | sort -g -r | head -1)
    old_format=1
  else
    old_format=0
  fi
  if [ -z "$lwjgl_version" ];then
    echo -e "\e[91mThe version for LWJGL could not be determined for $json_file\e[0m"
    # remove game version from json folder
    rm "$GIT_DIR/version-json/$json_file"
    # remove game version from manifest
    jq 'del(.versions[] | select(.id == "'${json_file:2:-5}'"))' "$GIT_DIR/mc/game/version_manifest_v2_noncompact.json" | sponge "$GIT_DIR/mc/game/version_manifest_v2_noncompact.json"
    continue
  else
    echo "minecraft version $json_file uses lwjgl: $lwjgl_version"
    cat "$json_file" | jq 'del(.libraries[] | select(.name | contains("org.lwjgl")))' > "$GIT_DIR/version-json/$json_file"
  fi

  # "name": "net.java.jinput:jinput:2.0.5"
  jinput_version=$(cat "$GIT_DIR/version-json/$json_file" | jq -r '.libraries | .[] | .name | select(contains("net.java.jinput:jinput-platform:"))' | sed 's/net.java.jinput:jinput-platform://g' | sed '/:/d' | head -1)
  if [ ! -z "$jinput_version" ];then
    echo "minecraft version $json_file uses jinput: $jinput_version"
    cat "$GIT_DIR/version-json/$json_file" | jq 'del(.libraries[] | select(.name | contains("net.java.jinput")))' | sponge "$GIT_DIR/version-json/$json_file"
  fi

  # 3.3.1 3.2.2 3.2.1 3.1.6 3.1.2 2.9.4-nightly-20150209 2.9.3 2.9.1 2.9.1-nightly-20131120 2.9.0
  if [[ "$lwjgl_version" =~ "2.9" ]]; then
    spruce merge "$GIT_DIR/version-json/$json_file" "$GIT_DIR/mc-static-json/2.9.4-nightly-20150209.json" | spruce json | sponge "$GIT_DIR/version-json/$json_file"
  elif [[ "$lwjgl_version" =~ ^(3.1.2|3.1.6|3.2.1|3.2.2|3.3.1|3.3.2|3.3.3)$ ]]; then
    spruce merge "$GIT_DIR/version-json/$json_file" "$GIT_DIR/mc-static-json/$lwjgl_version.json" | spruce json | sponge "$GIT_DIR/version-json/$json_file"
  else
    echo -e "\e[91mThis version of LWJGL ($lwjgl_version) is not recognized\e[0m"
    # remove game version from json folder
    rm "$GIT_DIR/version-json/$json_file"
    # remove game version from manifest
    jq 'del(.versions[] | select(.id == "'${json_file:2:-5}'"))' "$GIT_DIR/mc/game/version_manifest_v2_noncompact.json" | sponge "$GIT_DIR/mc/game/version_manifest_v2_noncompact.json"
    continue
  fi

  # modify version_manifest_v2.json
  sha1=$(sha1sum "$GIT_DIR/version-json/$json_file" | awk '{ print $1 }')
  # generate URL safe path
  json_url=$(echo "${json_file:2}" | sed -f "$GIT_DIR/url_escape.sed")
  jq '(.versions[] | select(.id == "'${json_file:2:-5}'") | .sha1) |= "'$sha1'" | (.versions[] | select(.id == "'${json_file:2:-5}'") | .url) |= "'https://github.com/theofficialgman/piston-meta-arm64/raw/main/version-json/$json_url'"' "$GIT_DIR/mc/game/version_manifest_v2_noncompact.json" | sponge "$GIT_DIR/mc/game/version_manifest_v2_noncompact.json"
  
done

# generate modified version_manifest.json
cat "$GIT_DIR/mc/game/version_manifest_v2_noncompact.json" | jq 'del(.versions[].sha1) | del(.versions[].complianceLevel)' > "$GIT_DIR/mc/game/version_manifest_noncompact.json"

# compact version_manifest files
cat "$GIT_DIR/mc/game/version_manifest_noncompact.json" | jq -c > "$GIT_DIR/mc/game/version_manifest.json"
cat "$GIT_DIR/mc/game/version_manifest_v2_noncompact.json" | jq -c > "$GIT_DIR/mc/game/version_manifest_v2.json"

IFS="$OIFS"

cd "$GIT_DIR"
