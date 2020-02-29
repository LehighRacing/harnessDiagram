#!/bin/bash
helpCalled(){
	echo -e "Usage: $0 [-h|--help] [-i|--input FILE] [-o|--output FILE]"
	printf "\t%s\t%s\n" "-h|--help" "Print this message and quit."
	printf "\t%s\t%s\n" "-i|--input" "File to read input (.csv) from instead of stdin."
	printf "\t%s\t%s\n" "-o|--output" "File to write output (.dot) to instead of stdout."
	printf "\t%s\t%s\n" "-e|--error" "File to write to instead of stderr."
	exit $1
}
parseCmd(){
	while [[ $1 ]]
	do
		case $1 in
			-i|--input)
				IN=$2
				shift
				;;
			-o|--output)
				OUT=$2
				shift
				;;
			-e|--output)
				ERR=$2
				shift
				;;
			-h|--help)
				helpCalled 0 > $ERR
				;;
			*)
				echo -e "$0: invalid option -- '$1'" > $ERR
				helpCalled 1 > $ERR
		esac
		shift
	done
}
IN=/dev/stdin
OUT=/dev/stdout
ERR=/dev/stderr
parseCmd $@
echo -e "\
graph harness{
	graph [
		layout=dot
		rankdir=TB
		splines=\"ortho\"
		bgcolor=\"transparent\"
	]
	node [
		shape=\"rectangle\"
	]
	edge [
		fontsize=3
		labelangle=180
		labeldistance=0.4
	]
	ECU [
		height=2.5
		//width=2
	]" > $OUT
while read line
do
	NAME=$(echo $line | cut -d, -f1)
	COLOR=$(echo $line | cut -d, -f2 |\
		sed "s/\//:/g;\
			s/^\([^:]*\):\([^:]*\)/\2:\1/g;
			s/^\([^:]*\):\([^:]*\)/\1:\2:\1:\2:\1:\2:\1:\2:\1:\2:\1:\2:\1:\2:\1:\2:\1:\2:\1:\2;0.05/g;
			s/White/Grey/g;
			s/Yellow/Goldenrod1/g")
	GAUGE=$(echo $line | cut -d, -f3)
	WIDTH="1.0"
	case $GAUGE in
		22)WIDTH="0.25";;
		20)WIDTH="0.5";;
		18)WIDTH="0.75";;
		16)WIDTH="1.0";;
		14)WIDTH="1.5";;
	esac
	FROM=$(echo $line | cut -d, -f4)
	FROMPIN=$(echo $line | cut -d, -f5)
	TO=$(echo $line | cut -d, -f6)
	TOPIN=$(echo $line | cut -d, -f7)
	#echo -e $NAME\\n$FROM-\>$TO\\n$COLOR
	echo -e "\t\"$FROM\" -- \"$TO\" [
		xlabel=\"$NAME $GAUGE AWG\"
		fontcolor=\"$COLOR\"
		color=\"$COLOR\"
		headlabel=\"$TOPIN\"
		taillabel=\"$FROMPIN\"
		penwidth=$WIDTH
	]"
done <<< $(cat $IN | tail -n+2 | cut -d, -f1,4,7,13,14,15,16) >> $OUT #NAME,COLOR,GAUGE,FROM,FROMPIN,TO,TOPIN
echo -e "}" >> $OUT
