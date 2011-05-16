# Copyright (C) 2009 One Laptop Per Child
# Licensed under the terms of the GNU GPL v2 or later; see COPYING for details.

set -e

libdir=$OOB__libdir
bindir=$OOB__bindir
builddir=$OOB__builddir
cachedir=$OOB__cachedir
intermediatesdir=$OOB__intermediatesdir
outputdir=$OOB__outputdir
statedir=$OOB__statedir
fsmount=$OOB__fsmount

read_config() {
	local vname="CFG_$1__$2"
	echo ${!vname}
}

read_buildnr() {
	local buildnr_path=$intermediatesdir/buildnr
	if [[ -e $buildnr_path ]]; then
		echo "$(<$buildnr_path)"
	else
		echo "0"
	fi
}

image_name() {
	local name_tmpl=$(read_config global image_name)
	printf $name_tmpl $(read_buildnr)
}

# hard link a file, but fall-back on copy if a device boundary is being crossed
ln_or_cp() {
	local src=$1
	local dest=$2
	local src_dev=$(stat -c "%D" "$src")
	local dest_dev=$(stat -c "%D" "$dest")
	if [ "$src_dev" = "$dest_dev" ]; then
		cp -l "$src" "$dest"
	else
		cp "$src" "$dest"
	fi
}

install_sugar_bundle() {
	mkdir -p "$intermediatesdir/shared/sugar-bundles"
	ln_or_cp "$1" "$intermediatesdir/shared/sugar-bundles"
}

