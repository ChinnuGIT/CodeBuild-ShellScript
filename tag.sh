#!/bin/bash

CURTAG=`git describe --abbrev=0 --tags`;
CURTAG="${CURTAG/v/}"

IFS='.' read -a vers <<< "$CURTAG"

MAJ=${vers[0]}
MIN=${vers[1]}
BUG=${vers[2]}
echo "Current Tag: v$MAJ.$MIN.$BUG"

for cmd in "$@"
do
	case $cmd in
		"--major")
			# $((MAJ+1))
			((MAJ+=1))
			MIN=0
			BUG=0
			echo "Incrementing Major Version#"
			;;
		"--minor")
			((MIN+=1))
			BUG=0
			echo "Incrementing Minor Version#"
			;;
		"--bug")
			((BUG+=1))
			echo "Incrementing Bug Version#"
			;;
	esac
done
NEWTAG="v$MAJ.$MIN.$BUG"
echo "Adding Tag: $NEWTAG";
git tag -a $NEWTAG -m $NEWTAG

export MSYS2_ARG_CONV_EXCL="*"
read -p "Enter the parameter name :" parameter_name
git tag --sort=committerdate | grep -E '[0-9]' | tail -1
latestTag=$(git tag --sort=committerdate | grep -E '[0-9]' | tail -1)
echo $latestTag

aws ssm put-parameter \
    --name "$parameter_name" \
    --type "String" \
    --value "$latestTag" \
	--tier Standard \
    --overwrite

aws codepipeline start-pipeline-execution --name Tag-Demo