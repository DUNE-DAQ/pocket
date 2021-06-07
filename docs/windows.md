# Windows compatibility

You will need to install [Docker Desktop](https://docs.docker.com/docker-for-windows/wsl/).  
After that, docker will be available both to powershell and windows subsystem for linux (WSL).

## Running in WSL
There are no special requirements. You should be able to `apt install git make`, clone Pocket, and run `setup.local`

## Running in PowerShell
You will need to install make and git, I suggest you do that via [Choco](https://chocolatey.org/).

Also, instead of running `eval $(make env)`, you have to run `make env | Invoke-Expression`.

TODO: /usr/bin/sh: -c: line 0: syntax error near unexpected token `('
/usr/bin/sh: -c: line 0: `head -c32 <(tr -dc _A-Z-a-z-0-9-=%. < /dev/urandom 2> /dev/null)'