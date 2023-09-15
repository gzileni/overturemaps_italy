#!/bin/bash

wget https://github.com/planetlabs/gpq/releases/download/v0.11.0/gpq-linux-amd64.tar.gz
tar xfvz gpq-linux-amd64.tar.gz 
chmod 755 gpq
regions="abruzzo basilicata calabria campania emiliaromagna friuliveneziagiulia lazio liguria lombardia marche molise piemonte puglia sardegna sicilia toscana trentinoaltoadige umbria valledaosta veneto"
url="https://s3.eu-central-1.amazonaws.com/overturemaps.italy/"
placeslbl="places_"
gpkglbl=".gpkg"
parquetlbl=".parquet"
buildingslbl="buildings_"

for r in $regions 
do
	d="$url$placeslbl$r$gpkglbl"
	wget $d
	/duckdb/duckdb -c "INSTALL httpfs; LOAD httpfs; INSTALL spatial; LOAD spatial; SET s3_region='us-west-2'; CREATE TABLE $placeslbl$r as select * from st_read('$placeslbl$r$gpkglbl', layer='$placeslbl$r');ALTER TABLE $placeslbl$r  RENAME geom TO geometry;COPY (SELECT * FROM $placeslbl$r ) TO 'tmp.parquet' (FORMAT PARQUET, CODEC 'ZSTD');"
	rm $placeslbl$r$gpkglbl
	./gpq convert tmp.parquet $placeslbl$r$parquetlbl
	rm tmp.parquet
done;

for r in $regions 
do
	d="$url$buildingslbl$r$gpkglbl"
	wget $d
	/duckdb/duckdb -c "INSTALL httpfs; LOAD httpfs; INSTALL spatial; LOAD spatial; SET s3_region='us-west-2'; CREATE TABLE $buildingslbl$r as select * from st_read('$buildingslbl$r$gpkglbl', layer='$r');ALTER TABLE $buildingslbl$r  RENAME geom TO geometry;COPY  (SELECT * FROM $buildingslbl$r ) TO 'tmp.parquet' (FORMAT PARQUET, CODEC 'ZSTD');"
	rm $buildingslbl$r$gpkglbl
	./gpq convert tmp.parquet $buildingslbl$r$parquetlbl
	rm tmp.parquet
done;