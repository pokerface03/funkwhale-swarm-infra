echo "Run on Worker Node"
echo ""
echo "Note:"
echo "If the PostgreSQL container is running, the backup may not be fully consistent due to active writes."
echo "Consider stopping the container or using pg_dump for consistent backups."

docker run --rm \
  -v postgres-primary-data:/var/lib/postgresql/pdata \
  -v $(pwd):/backup \
  busybox \
  tar -zcvf /backup/pgcluster_primary_backup.tar.gz -C /var/lib/postgresql/pdata .

docker run --rm \
  -v postgres-replica-data:/var/lib/postgresql/rdata \
  -v $(pwd):/backup \
  busybox \
  tar -zcvf /backup/pgcluster_replica_backup.tar.gz -C /var/lib/postgresql/rdata .
