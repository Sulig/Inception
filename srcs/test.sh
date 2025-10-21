#!/bin/bash
echo "=== Testing Inception ==="
echo "1. Contenedores:"
docker ps -a
echo ""
echo "2. Logs WordPress:"
docker logs wordpress --tail 10
echo ""
echo "3. Logs MariaDB:"
docker logs mariadb --tail 5
echo ""
echo "4. Logs Nginx:"
docker logs nginx --tail 5
echo ""
echo "5. Red:"
docker network inspect srcs_inception --format='{{range .Containers}}{{.Name}} {{.IPv4Address}}{{"\n"}}{{end}}'
