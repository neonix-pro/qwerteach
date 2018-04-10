#!/bin/bash
rm tmp/pids/server.pid

rackup private_pub.ru -s thin -E production -o 0.0.0.0 -D
#thin -C config/private_pub_thin.yml  -o 0.0.0.0 -D start
BACKGROUND=yes rake resque:scheduler
PIDFILE=./resque.pid BACKGROUND=yes QUEUE=* rake resque:work

rails server puma -e development -p 3000 -b '0.0.0.0'
