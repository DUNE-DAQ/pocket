#!/bin/bash

/src/dqm-backend/dqm/./prepare_dqm

cd /src/dqm-backend/dqm/dqm/
exec /usr/local/bin/daphne dqm.asgi:application -b 0.0.0.0 -p 8000
