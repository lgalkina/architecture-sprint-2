#!/bin/bash

docker compose exec -T mongodb1 mongosh --quiet <<EOF
use somedb
db.helloDoc.countDocuments()
EOF