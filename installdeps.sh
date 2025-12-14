#!/bin/env bash

PACKAGEMANAGER=


echo "Detecting your package manager and updating package lists..."
if (command -v pacman >/dev/null); then
	PACKAGEMANAGER="pacman -S"
	sudo pacman -Sy
elif (command -v apt >/dev/null); then
	PACKAGEMANAGER="apt install"
	sudo apt update
else
	echo "no supported package manager installed. you're on your own."


if (command -v git >/dev/null); then echo -n ""; else
	if [ null$PACKAGEMANAGER = null ]; then
		echo "Git is not installed. Please use your system"
		echo "  package manager to install git."
		exit 1
	else	
		$PACKAGEMANAGER git
	fi
fi
if (command -v cargo >/dev/null); then echo -n ""; else
	if [ null$PACKAGEMANAGER = null ]; then
		echo "Cargo is not installed. Please use your system"
		echo "  package manager to install cargo."
		exit 1
	else
		$PACKAGEMANAGER cargo
	fi
fi

mkdir deps
cd deps
echo "preparing to compile chumcli (extracts files from NGC/DGC and NPC/DPC archives)..."
git clone -n https://github.com/Jellonator/chum-world.git
cd chum-world
git checkout -q afdb15845eec18ee964b1ebea7019ff45a0dce66 #last commit before a breaking change was made to chumlib
cd chumcli
cargo build
cp target/debug/chumcli ../../
cd ../../
rm -rf chum-world
echo "compiling chumcli complete."
echo "preparing to compile gc-gcm (extracts files from gcm disc image (gamecube disc))"
PATH=./bin:$PATH CARGO_INSTALL_ROOT=./ cargo install gc-gcm --features=bin 
mv ./bin/gcm .
rmdir bin
rm .crates.toml .crates2.json
echo "compiling gc-gcm complete."

if (command -v pycdc >/dev/null) then echo -n ""; else
	echo "pycdc is not installed. Please use your system"
	echo "  package manager to install pycdc."
	echo "  e.g. \`snap install pycdc\` on ubuntu"
	echo "  or install it from the aur on arch:"
	echo "    \`git clone https://aur.archlinux.org/pycdc-git.git\`"
	echo "    \`cd pycdc                                         \`"
	echo "    \`makepkg -sic                                     \`"
fi

echo "downloading python 2.1 from https://www.python.org/ftp/python/2.1.3/Python-2.1.3.exe"
curl -o "./python-2.1.exe" "https://www.python.org/ftp/python/2.1.3/Python-2.1.3.exe"
echo "download complete."

if (command -v wine >/dev/null) then echo -n ""; else
	if [ null$PACKAGEMANAGER = null ]; then
		echo "Wine is not installed. Please use your system"
		echo "  package manager to install wine."
	else
		$PACKAGEMANAGER wine
	fi
fi
