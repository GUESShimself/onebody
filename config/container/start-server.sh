# start-server.sh

#!/bin/bash
cd /onebody
source /etc/profile.d/rvm.sh
bundle exec rails server -d -p 8080
