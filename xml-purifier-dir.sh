#!/bin/bash

xmlfiles_dir=${1%/} #$(dirname "$1")
xslt=${2%/} #$(dirname "$1")
help () {

   echo ""
   echo "**********************************************************"
   echo "  usage: $(basename $0) /path/to/bad-xml/files /path/to/xslt/file"
   echo "  outputs: copy files to ./cleaned-xml"
   echo "**********************************************************"
   echo ""
}

if [ $# -lt 2 ] ;
then
        help
        exit 1
fi

if [ ! -d "$xmlfiles_dir" ]
then
   echo "$xmlfiles_dir is not a directory"
   exit 1
fi

echo "Using..."
echo $xmlfiles_dir
echo $xslt


# Create Output Directory
mkdir -p ./cleaned-xml
cleaned=./cleaned-xml

echo $xslt

if [ -d ./cleaned-xml ]
then
  for f in $xmlfiles_dir/*.xml
  do
   if [[ $f == *.xml ]]
   then
     #xmlfile = $(basename $f)
     result=`java -jar /tmp/saxon9he.jar -o:$cleaned/$(basename $f) $f $xslt `
     #result=`xmllint --noout --schema /home/nruest/mods.xsd $f 2> validator-script.log`
     echo "$cleaned/$(basename $f)"
   else
     echo "$f is NOT XML"
   fi
  done
  echo "Check cleaned-xml folder for output files"
fi
