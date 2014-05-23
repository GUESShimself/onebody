# Dockerfile for Onebody

# Select ubuntu as the base image
FROM phusion/baseimage

# Install prereqs
RUN apt-get update -q
#RUN apt-get install -qy nginx
RUN apt-get install -qy build-essential
RUN apt-get install -qy curl
RUN apt-get install -qy libcurl4-openssl-dev
RUN apt-get install -qy mysql-server
RUN apt-get install -qy libmysqlclient-dev
#RUN apt-get install -qy rubymysql2
RUN apt-get install -qy nodejs
#RUN echo "daemon off;" >> /etc/nginx/nginx.conf
#RUN apt-get install -qy apache2

# Install rvm, ruby, bundler
RUN echo insecure >> ~/.curlrc
RUN curl -sSL --insecure https://get.rvm.io | bash -s stable
RUN /bin/bash -l -c "rvm requirements"
RUN /bin/bash -l -c "rvm install 2.1.0"
RUN /bin/bash -l -c "gem install bundler --no-ri --no-rdoc"

# Add configuration files in repository to filesystem
#ADD config/container/nginx-sites.conf /etc/nginx/sites-enabled/default
ADD config/container/start-server.sh /usr/bin/start-server
RUN chmod +x /usr/bin/start-server

# Add rails project to project directory
ADD ./ /onebody

# set WORKDIR
WORKDIR /onebody

# bundle install
RUN mysql -u root -e "create database onebody_dev; grant all on onebody_dev.* to onebody@localhost identified by 'onebody';"
RUN cp config/database.yml{.example,}
RUN /bin/bash -l -c "bundle install"
RUN cp config/secrets.yml{.example,}
RUN rake db:migrate

# Publish port 80
EXPOSE 8080

# Startup commands
ENTRYPOINT /usr/bin/start-server
