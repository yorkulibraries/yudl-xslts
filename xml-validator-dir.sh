#!/bin/bash

xmlfiles_dir=${1%/} #$(dirname "$1")
help () {

   echo ""
   echo "**********************************************************"
   echo "  usage: $(basename $0) /path/to/xml/files"
   echo "  outputs: copy files to ./bad-xml/* and ./good-xml/*"
   echo "**********************************************************"
   echo ""
}

if [ $# -lt 1 ] ;
then
        help
        exit 1
fi

#echo "I passed arg check"
#echo $xmlfiles_dir

if [ ! -d "$xmlfiles_dir" ]
then
   echo "$xmlfiles_dir is not a directory"
   exit 1
fi


mkdir -p ./bad-xml
mkdir -p ./good-xml
#mkdir -p ./exit-1-xml

if [ -d ./bad-xml ] && [ -d ./good-xml ]
then
  for f in $xmlfiles_dir/*.xml
  do
   if [[ $f == *.xml ]]
   then 
     result=`xmllint --noout --schema /home/nruest/mods.xsd $f`
     status=$?

     #echo "Status: $status"
     if [ $status == "0" ]
     then
       cp $f ./good-xml/$(basename $f)
     elif [ $status == "1" ]
     then
       echo "EXIT CODE=1: $f, look into it!..."
       #cp $f ./exit-1-xml/$(basename $f)
     else
       #echo "Bad $f, copying..."
       cp $f ./bad-xml/$(basename $f)
     fi 
   else
     echo "$f is NOT XML"
   fi
  done
  exit 0
fi
