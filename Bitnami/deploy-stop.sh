

cat pg-nodes | xargs -I {} docker node update --label-rm pgcluster {}



############## deploy ######################################
docker stack rm pgcluster
############## deploy ######################################
