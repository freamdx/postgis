#!/bin/bash

# gpapp path, maybe change
gpappdir=/u01/gpdb
libdir=$gpappdir/spatiallib

# postgis source path
srcdir=$(pwd)
dependsdir=$srcdir/depends
geosdir=$srcdir/depends/geos
projdir=$srcdir/depends/proj
gdaldir=$srcdir/depends/gdal

rm -rf $dependsdir && mkdir -p $dependsdir
cd $dependsdir && git clone https://github.com/libgeos/geos.git && cd $geosdir && git checkout -b 3.8.0 3.8.0
cd $dependsdir && git clone https://github.com/OSGeo/PROJ.git && cd $projdir && git checkout -b 4.9.3 4.9.3
cd $dependsdir && git clone https://github.com/OSGeo/gdal.git && cd $gdaldir && git checkout -b 2.4.3 v2.4.3

cd $geosdir && ./autogen.sh && ./configure --prefix=$libdir
make -j8 install

cd $projdir && ./autogen.sh && ./configure --prefix=$libdir
make -j8 install

#sudo yum install sqlite-devel
cd $gdaldir/gdal && ./configure --with-geos=$libdir/bin/geos-config --with-proj=$libdir --prefix=$libdir
make -j8 install

cd $srcdir && ./autogen.sh
./configure --prefix=$libdir \
	    --without-topology \
	    --with-pgconfig=$gpapp/bin/pg_config \
	    --with-geosconfig=$libdir/bin/geos-config \
	    --with-gdalconfig=$libdir/bin/gdal-config \
	    --with-projdir=$libdir \
CFLAGS="-O2 -Wno-implicit-fallthrough"
make -j8 install

# add config to ~/.bash_profile
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$libdir/lib:$libdir/lib64
export PATH=$PATH:$libdir/bin
