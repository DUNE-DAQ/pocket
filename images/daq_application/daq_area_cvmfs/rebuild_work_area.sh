#!/usr/bin/bash
HERE=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

if [[ $# -ne 1 ]]; then
    echo "ERROR: Wrong number of arguments: 1 expecgted, $# found."
    exit 2
fi

if [[ ! -d $1 && ( -L $1 && ! -d "$(readlink $1)" ) ]]; then
    echo "$1 is not a directory"
    exit 2
fi

DBT_AREA=$1

echo "------------------------------------------"
echo "Rebuilding dbt work area in $DBT_AREA"
echo "------------------------------------------"
cd $DBT_AREA
source ./dbt-env.sh
dbt-workarea-env
dbt-build -c
rm -rf build
make_env_script.sh
echo "------------------------------------------"
echo "Rebuild completed"
echo "------------------------------------------"
