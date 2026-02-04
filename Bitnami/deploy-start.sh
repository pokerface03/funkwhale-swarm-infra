########################     create-secrets ################################3

openssl rand -base64 32 > /home/fedlab18/keys/pgcluster/secrets/postgres_root_password
openssl rand -base64 32 > /home/fedlab18/keys/pgcluster/secrets/replicator_password
openssl rand -base64 32 > /home/fedlab18/keys/pgcluster/secrets/repmgr_password


cat pg-nodes | xargs -I {} docker node update --label-add pgcluster=true {}



############## deploy ######################################
docker stack deploy -c docker-compose.yml pgcluster
############## deploy ######################################

