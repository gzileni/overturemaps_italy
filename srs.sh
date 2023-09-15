#!/bin/bash

for i in `ls *.gpkg`;
  do
    name=`basename $i .gpkg`;
    tmpname=`echo $name`_tmp.gpkg;
    echo "assign WGS84 to $i";
    ogr2ogr -a_srs EPSG:4326 -f "GPKG" $tmpname $i;
    mv $tmpname $i;
    echo "done!";
done