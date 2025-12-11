#!/bin/env bash

# All filepaths referenced here are relative to the current working directory. This is to allow the tool to be placed anywhere on $PATH as 
# long as `installdeps.sh` was able to generate the compilation dependencies folder

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 path/to/disc.iso/or/discfiles {pc|ps2|gcn}"
    exit 1
fi


DISCFILESPATH=${1//.iso/}
if [ "$1" == *".iso" ]; then
	deps/gcm extract $1 $DISCFILESPATH  #extract files from disc
fi

if   [ -d "$DISCFILESPATH/DATA/" ]; then
	DATAPATH="$DISCFILESPATH/DATA/"
elif [ -d "$DISCFILESPATH/data/" ]; then
	DATAPATH="$DISCFILESPATH/data/"
fi
DECOMPATH="./DATA-decompressed/"
SCRIPPATH="./DATA-levelscripts/"

if   [ "$2" == "ps2" ]; then
	NAMES=nps
	DATAS=dps
	MODE="--ps2"
elif [ "$2" == "pc"  ]; then
	NAMES=npc
	DATAS=dpc
	MODE="--ps2"
elif [ "$2" == "gcn" ]; then
	NAMES=NGC
	DATAS=DGC
	MODE="--ngc"
fi

DecompylePycFiles() {
	for k in $(ls $1); do
		echo -n "| Decompiling $1$k >>> ${1//$DECOMPATH/$SCRIPPATH}${k//.PYC/.py} ... "
		mkdir -p "${1//$DECOMPATH/$SCRIPPATH}"
		dd if=$1$k of=tmp.pyc bs=1 skip=4 2>/dev/null # remove first 4 bytes of file (random garbage?) Will be changed if needed.
		rm $1$k
		mv tmp.pyc $1$k
		if [[ "$k" == *".pyc" ]]; then
			pycdc -c $1$k -v 2.1 -o ${1//$DECOMPATH/$SCRIPPATH}${k//.PYC/.py} #decompile pyc file to the human readable .py format
		else
			cp $1$k ${1//$DECOMPATH/$SCRIPPATH}$k
		fi
		if (echo $? >/dev/null); then
			echo "Success"
		fi
	done
}

ExtractArchives() {
	for j in $(ls $1*.$NAMES | awk -F'/' '{print $NF}' | awk -F'.' '{print $1}'); do
		OUTPATH=${1//$DATAPATH/$DECOMPATH}$j
		echo -n "Extracting $1$j.{$NAMES,$DATAS} >>> $OUTPATH/ ... "
		deps/chumcli extract $1$j.$NAMES $1$j.$DATAS $OUTPATH/ --replace $MODE #extract NGC and DGC archive to decompressed files dir

		if [ -d "$OUTPATH/SCRIPTS" ]; then
			DecompylePycFiles $OUTPATH/SCRIPTS/*/PYTHON/ #run decompiler on the newly decompressed scripts
			DecompylePycFiles $OUTPATH/PYTHON/
		fi
	done
}

#actual program start (the above is defining the functions that will be run)

ExtractArchives $DATAPATH

for i in $(ls -d $DATAPATH*/); do
	ExtractArchives $i
done
