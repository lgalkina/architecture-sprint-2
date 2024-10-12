#!/bin/bash

###
# Подключитесь к серверу конфигурации и сделайте инициализацию
###

docker compose exec -T configSrv mongosh --port 27017 --quiet <<EOF
rs.initiate({_id:"config_server",configsvr:true,members:[{_id:0,host:"configSrv:27017"}]})
exit()
EOF

###
# Инициализируйте шарды
###

docker compose exec -T shard1 mongosh --port 27018 --quiet <<EOF
rs.initiate({_id:"shard1",members:[{_id:0,host:"shard1:27018"}]})
exit()
EOF

docker compose exec -T shard2 mongosh --port 27019 --quiet <<EOF
rs.initiate({_id:"shard2",members:[{_id:0,host:"shard2:27019"}]})
exit()
EOF

###
# Инициализируем роутер
###

sleep 5  # ждем 5 сек
docker compose exec -T mongos_router mongosh --port 27020 --quiet <<EOF
sh.addShard("shard1/shard1:27018")
sh.addShard("shard2/shard2:27019")
sh.enableSharding("somedb")
sh.shardCollection("somedb.helloDoc",{"name":"hashed"})
EOF

###
# Инициализируем бд
###

docker compose exec -T mongos_router mongosh --port 27020 --quiet <<EOF
use somedb
for(var i = 0; i < 2000; i++) db.helloDoc.insertOne({age:i, name:"ly"+i})
EOF
