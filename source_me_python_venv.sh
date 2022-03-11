if [ -z "$HTTP_PROXY" ];
then
    echo "setup the proxy first, otherwise pip won't work";
    return
fi

python -m venv env

source env/bin/activate

pip install --upgrade pip

python -m pip install pymongo
