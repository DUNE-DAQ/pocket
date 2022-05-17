#!/usr/bin/bash

if [[ $# -ne 2 ]]; then
    echo "ERROR: Wrong number of arguments: 2 expecgted, $# found."
    exit 2
fi

if [[ ! -d $1 && ( -L $1 && ! -d "$(readlink $1)" ) ]]; then
    echo "$1 is not a directory"
    exit 2
fi

SRC_AREA=$(cd $1 && pwd)
DST_AREA=$2

echo "------------------------------------------"
echo "Rsync'ing daq area to $DST_AREA"
echo "------------------------------------------"
rsync -av --info=progress2 --info=name0 --exclude build --exclude install --exclude dbt-pyvenv ${SRC_AREA}/ ${DST_AREA}/

echo "------------------------------------------"
echo "Recreating 'build/'"
echo "------------------------------------------"
mkdir ${DST_AREA}/build
cd ${SRC_AREA}

echo "------------------------------------------"
echo "Loading dbt environment"
echo "------------------------------------------"
source dbt-env.sh
dbt-workarea-env -s systems

echo "------------------------------------------"
echo "Cloning python venv"
echo "------------------------------------------"
clonevirtualenv.py ${SRC_AREA}/dbt-pyvenv ${DST_AREA}/dbt-pyvenv
