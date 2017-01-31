#!/bin/bash
###############################################################################
#
# THIS SCRIPT IS USED TO REPLACE  STRING FOR ALL FILES
# Auther:   York Chen
# Email:    york.chen@istuary.com
# Date:     2017-01-31
# Usage:    replace.sh <find>  <replacewith> 
# Example:  findmvn.sh "org.opendaylight." "com.istuary"
#
###############################################################################


if [ ! $# == 2 ]; then
   echo "Echo  $0  <find>  <replacewith>"
   exit
fi

find=$1
replacewith=$2
para="'s/$find/$replacewith/g'"
echo $para
xmls=$(find -name "*.xml")
javas=$(find -name "*.java")
yangs=$(find -name "*.yang")

for xml in $xmls
do
   echo $xml
   sed -i "s/$find/$replacewith/g" $xml
done


for java in $javas
do 
   echo $java
   sed -i "s/$find/$replacewith/g" $java
done

for yang in $yangs
do
   sed -i "s/$find/$replacewith/g" $yang
done

