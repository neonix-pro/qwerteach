#!/bin/bash
rm tmp/pids/server.pid

rackup private_pub.ru -s thin -E production -o 0.0.0.0 -D
BACKGROUND=yes rake resque:scheduler
PIDFILE=./resque.pid BACKGROUND=yes QUEUE=* rake resque:work

rails server -e development -p 3000 -b '0.0.0.0'
