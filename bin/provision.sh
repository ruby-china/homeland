sudo update-locale LC_ALL="en_US.utf8"

# Add Elasticsearch sources
wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb http://packages.elastic.co/elasticsearch/2.x/debian stable main" | sudo tee -a /etc/apt/sources.list.d/elasticsearch-2.x.list

# Add PG sources
echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" | sudo tee -a /etc/apt/sources.list.d/pgdb.list
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

# Add Ruby sources
sudo add-apt-repository ppa:brightbox/ruby-ng
sudo add-apt-repository ppa:chris-lea/redis-server

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y git \
                        redis-server \
                        memcached \
                        imagemagick \
                        nodejs \
                        libpq-dev \
                        postgresql-9.4 \
                        elasticsearch \
                        openjdk-7-jre-headless \
                        ruby2.3 \
                        ruby2.3-dev

sudo update-rc.d elasticsearch defaults
sudo service elasticsearch start

sudo su postgres -c "createuser -d -R -S $USER"

gem sources --add https://ruby.taobao.org/ --remove https://rubygems.org/

sudo gem install bundler
bundle config mirror.https://rubygems.org https://ruby.taobao.org
