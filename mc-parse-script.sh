#!/bin/bash

GIT_DIR=$(pwd)

mkdir -p /tmp/test
cd /tmp/test || exit
rm -rf /tmp/test/*
# mkdir updated_json
mkdir original_json
# mkdir original_json_jq

wget https://piston-meta.mojang.com/mc/game/version_manifest_v2.json
cat version_manifest_v2.json | jq -r '.versions[].url' > urls.txt

cd original_json
wget -i ../urls.txt

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
    echo "minecraft version $json_file use lwjgl: Unknown"
    break
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
  elif [[ "$lwjgl_version" =~ ^(3.1.2|3.1.6|3.2.1|3.2.2|3.3.1)$ ]]; then
    spruce merge "$GIT_DIR/version-json/$json_file" "$GIT_DIR/mc-static-json/$lwjgl_version.json" | spruce json | sponge "$GIT_DIR/version-json/$json_file"
  else
    echo -e "\e[91mThis version of LWJGL ($lwjgl_version) is not recognized\e[0m"
  fi
  
done
IFS="$OIFS"

cd "$GIT_DIR"