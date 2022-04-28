#!/bin/bash

cd /src/dqm-backend/dqm/dqm/
exec "daphne dqm.asgi:application -b 0.0.0.0 -p 8000"
