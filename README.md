# piston-meta-arm64

This repo hosts a replacement Minecraft Java Manifest for ARM64 Linux.
Minecraft has a manifest file that tells minecraft launchers where the files are located on the intenet, what files go with what version of the game, and what launch arguments to launch the game with.
See the wiki for more info: https://minecraft.wiki/w/Version_manifest.json

This repo takes advantage of this by parsing and rewriting the official meta repo for unofficial ARM64 linux support.

If you are looking for ARM32 linux, I have a separate repo for that here -> https://github.com/theofficialgman/piston-meta-arm32

## How to use this

Minecraft launchers can be modified to use this meta repo instead of mojangs meta repo. For open source launchers, sometimes this is as simple as changing a string from `https://launchermeta.mojang.com/mc/game/version_manifest.json` to this manifest `https://raw.githubusercontent.com/theofficialgman/piston-meta-arm64/main/mc/game/version_manifest.json` and building the launcher.
(or for the v2 version `https://launchermeta.mojang.com/mc/game/version_manifest_v2.json` to `https://raw.githubusercontent.com/theofficialgman/piston-meta-arm64/main/mc/game/version_manifest_v2.json`)

GDLauncher required minimal changes for a functional build: https://github.com/gorilla-devs/GDLauncher/pull/1451<br>
Builds for ARM64 Linux here: <br>
Get it from [pi-apps](https://github.com/Botspot/pi-apps)<br>
https://github.com/Pi-Apps-Coders/files/releases/download/large-files/GDLauncher-linux-arm64-1.1.29-setup.AppImage<br>
https://github.com/Pi-Apps-Coders/files/releases/download/large-files/GDLauncher-linux-arm64-1.1.29-setup.deb<br>
https://github.com/Pi-Apps-Coders/files/releases/download/large-files/GDLauncher-linux-arm64-1.1.29-setup.rpm<br>
https://github.com/Pi-Apps-Coders/files/releases/download/large-files/GDLauncher-linux-arm64-1.1.29-setup.zip<br>

## This repo uses my (theofficialgman) already existing ARM64 lwjgl/jinput ports:
- LWJGL 2.9.4-nightly-20150209 (for minecraft 1.12 and older)<br>
- jinput 2.0.7 (it appears that jinput 2.0.5 from mojang is actually closer to 2.0.7) a library used for game controllers on minecraft 1.12.2 and older, tested with this mod: https://github.com/ljsimin/MinecraftJoypadSplitscreenMod<br>
- backported versions of 3.1.6, 3.2.1, and 3.2.2 for armhf/arm64 compatibility, and a spoofed 3.1.2 (for prerelease 1.13 minecraft)<br>
- official lwjgl 3.3.1 armhf/arm64 linux builds are also included for use with Minecraft 22w16a (1.19 prerelease) and newer<br>

The only library that does not have a native arm64 version is the narrator library created by Mojang. This just means the in-game narrator is unavailable. The sources for this library are available but it is not easily buildable outside of microsoft's full build system. You can find the sources here: <https://libraries.minecraft.net/com/mojang/text2speech/1.13.9/text2speech-1.13.9-sources.jar> . Change the version number to match the desired version used in Minecraft. If anyone is able to build this library, create an issue in this repo.

## LWJGL/Jinput Binaries

https://github.com/theofficialgman/lwjgl3-binaries-arm64<br>

## Sources:

https://github.com/theofficialgman/lwjgl3 (check the `3.2.2-arm`, `3.2.1-arm`, and `3.1.6-arm` branches)<br>
https://github.com/theofficialgman/lwjgl (checkout the commit corresponding to `2.9.4-nightly-20150209`)<br>

https://github.com/jinput/jinput/tree/2.0.7<br>

FOSS Software [Spruce](https://github.com/geofffranks/spruce) is included in binary form in this repo to assist with automation, its license is found here: https://github.com/geofffranks/spruce/blob/master/LICENSE
