# Copyright (C) 2009 One Laptop Per Child
# Licensed under the terms of the GNU GPL v2 or later; see COPYING for details.

. $OOB__shlib
compress=$(read_config sd_card_image compress_disk_image)

oIFS=$IFS
IFS=$'\n'
for line in $(env); do
	[[ "${line:0:24}" == "CFG_sd_card_image__size_" ]] || continue
	vals=${line#*=}
	disk_size=${vals%,*}
	name=
	expr index "$vals" ',' &>/dev/null && name=${vals#*,}
	if [ -n "$name" ]; then
		osname=$(image_name)-$name
	else
		osname=$(image_name)
	fi
	pfx=$outputdir/$osname
	echo "Making ZD image for $osname..."
	$bindir/zhashfs 0x20000 sha256 $pfx.disk.img $pfx.zsp $pfx.zd

	echo "Creating MD5sum of $osname.zd..."
	pushd $outputdir >/dev/null
	md5sum $osname.zd > $osname.zd.md5
	popd >/dev/null

	if [[ "$compress" == "1" ]]; then
		echo "Compressing disk image..."
		tar -czS -f $pfx.disk.img.tar.gz -C $outputdir $osname.disk.img
		rm -f $pfx.disk.img
	fi
done
IFS=$oIFS

