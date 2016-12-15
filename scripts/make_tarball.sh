#!/bin/bash

## simple check to make sure we're in the right directory....
#git log &> /dev/null
#
#if [ $? -ne 0 ]; then
#	echo "Don't appear to be in the git directory."
#	exit 1
#fi
#
#RPM_SOURCES=$(rpm --eval '%{_sourcedir}' 2> /dev/null)
#
#if [ ! -d "$RPM_SOURCES" ]; then
#	echo "I want to put the tarball into the RPM_SOURCES sources directory, but \`rpm --eval '%{_sourcedir}'\` didn't return a directory that exists."
#	exit 1
#fi
#
#git_changes_work=$(git diff 2> /dev/null | wc -l)
#git_changes_index=$(git diff --cached 2> /dev/null | wc -l)
#
## add the two wc together
#git_changes=$(expr "$git_changes_work" "+" "$git_changes_index")
#
#if [ $git_changes -gt 0 ]; then
#
#	echo "You have differences between your working tree and/or index from the current HEAD."
#	echo "Please commit them before building the tarball."
#
#	exit 1
#
#fi

vfile=slab_pdc_version.h

NAME=`awk '/#define/{ print $2 " " $3}' ${vfile} | awk '/_NAME/{gsub("\"","");print $2}' | awk '{print tolower($0)}'`
MAJOR=`awk '/#define/{ print $2 " " $3}' ${vfile} | awk '/_MAJOR/{print $2}'`
MINOR=`awk '/#define/{ print $2 " " $3}' ${vfile} | awk '/_MINOR/{print $2}'`
PATCH=`awk '/#define/{ print $2 " " $3}' ${vfile} | awk '/_PATCH/{print $2}'`
MAINTAINER=`awk '/#define/{ print $2 " " $3}' ${vfile} | awk '/_MAINTAINER/{gsub("\"","");print $2}' | awk '{print tolower($0)}'`

version=$MAJOR.$MINOR.$PATCH
#version=$(grep VERSION module.c | cut -d '"' -f 2)

make clean

BRANCH=$(git branch | grep '^\*' | awk '{print $2}')

echo "Making tarball from the \"$BRANCH\" branch => ./slab_pdc-$version.tar.gz"
#echo "Making tarball from the \"$BRANCH\" branch => $RPM_SOURCES/slab_pdc-$version.tar.gz"

git archive --format=tar --prefix="slab_pdc-$version/" $BRANCH | gzip -9 > "./slab_pdc-$version.tar.gz"
#git archive --format=tar --prefix="slab_pdc-$version/" $BRANCH | gzip -9 > "$RPM_SOURCES/slab_pdc-$version.tar.gz"

