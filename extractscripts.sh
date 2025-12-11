#!/bin/env bash

# All filepaths referenced here are relative to the current working directory. This is to allow the tool to be placed anywhere on $PATH as 
# long as `installdeps.sh` was able to generate the compilation dependencies folder

DISCFILESPATH="./GSQE78"
deps/gcm extract GSQE78.iso $DISCFILESPATH  #extract files from disc

DATAPATH="$DISCFILESPATH/DATA/"
DECOMPATH="./DATA-decompressed/"
SCRIPPATH="./DATA-levelscripts/"

DecompylePycFiles() {
	for k in $(ls $1); do
		echo -n "| Decompiling $1$k >>> ${1//$DECOMPATH/$SCRIPPATH}${k//.PYC/.py} ... "
		mkdir -p "${1//$DECOMPATH/$SCRIPPATH}"
		dd if=$1$k of=tmp.pyc bs=1 skip=4 2>/dev/null # remove first 4 bytes of file (random garbage?) Will be changed if needed.
		rm $1$k
		mv tmp.pyc $1$k
		pycdc -c $1$k -v 2.1 -o ${1//$DECOMPATH/$SCRIPPATH}${k//.PYC/.py} #decompile pyc file to the human readable .py format
		if (echo $? >/dev/null); then
			echo "Success"
		fi
	done
}

ExtractArchives() {
	for j in $(ls $1*.NGC | awk -F'/' '{print $NF}' | awk -F'.' '{print $1}'); do
		OUTPATH=${1//$DATAPATH/$DECOMPATH}$j
		echo -n "Extracting $1$j.*GC >>> $OUTPATH/ ... "
		deps/chumcli extract $1$j.NGC $1$j.DGC $OUTPATH/ --replace --ngc #extract NGC and DGC archive to decompressed files dir

		if [ -d "$OUTPATH/SCRIPTS" ]; then
			DecompylePycFiles $OUTPATH/SCRIPTS/$j/PYTHON/ #run decompiler on the newly compressed scripts
			DecompylePycFiles $OUTPATH/PYTHON/
		fi
	done
}

#actual program start (the above is defining the functions that will be run)

ExtractArchives $DATAPATH

for i in $(ls -d $DATAPATH*/); do
	ExtractArchives $i
done
