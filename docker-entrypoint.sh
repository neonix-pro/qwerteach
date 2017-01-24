#!/bin/bash
rackup private_pub.ru -s thin -E production -o 0.0.0.0 -D
rails server -e development -p 3000 -b '0.0.0.0'