#!/bin/bash
shopt -s extglob

case "$1" in
'init')
	mkdir ./.myvcs
	printf 0 > ./.myvcs/.latest
	printf 0 > ./.myvcs/.head
	;;
'push')
	vers=$(sed -n '1p' < ./.myvcs/.latest)
	parent=$(sed -n '1p' < ./.myvcs/.head)
	let vers+=1
	mkdir ./.myvcs/$vers
	cp -r ./!(.myvcs) ./.myvcs/$vers
	printf $parent > ./.myvcs/$vers/.parent
	printf $vers > ./.myvcs/.latest
	printf $vers > ./.myvcs/.head
	if [ "$2" = '-m' ]
	then
		printf "%s :: %s %s :: %s\n" $vers $(date +"%D %T") "$3" >> ./.myvcs/.log
	else
		printf "%s :: %s %s\n" $vers $(date +"%D %T") >> ./.myvcs/.log
	fi
	;;
'checkout')
	vers=$(sed -n '1p' < ./.myvcs/.latest)
	vers=$(($vers > $2 ? $2 : $vers))
	rm -r ./!(.myvcs)
	cp -r ./.myvcs/$vers/!(.parent) ./
	printf $vers > ./.myvcs/.head
	;;
'latest')
	vers=$(sed -n '1p' < ./.myvcs/.latest)
	rm -r ./!(.myvcs)
	cp -r ./.myvcs/$vers/ ./
	;;
'current')
	echo $(sed -n '1p' < ./.myvcs/.head)
	;;
'log')
	parent=$(sed -n '1p' < ./.myvcs/.head)
	output=""
	while [ $parent != 0 ]
	do
		output="$(sed -n "${parent}p" < ./.myvcs/.log)\n$output"
		parent=$(sed -n '1p' < ./.myvcs/$parent/.parent)
	done
	echo -e $output
	;;
'diff')
	echo $(diff ./.myvcs/$2 ./.myvcs/$3)
	;;
esac
exit 0
