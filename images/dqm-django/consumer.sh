#!/bin/bash

/src/dqm-backend/dqm/./prepare_dqm

cd /src/dqm-backend/dqm/
exec python3 dqm/manage.py shell < scripts/consumer.py