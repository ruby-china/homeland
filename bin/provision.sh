sudo update-locale LC_ALL="en_US.utf8"

# Add Elasticsearch sources
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-5.x.list

# Add PG sources
echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" | sudo tee -a /etc/apt/sources.list.d/pgdb.list
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

# Add Ruby sources
sudo add-apt-repository ppa:brightbox/ruby-ng
sudo add-apt-repository ppa:chris-lea/redis-server
sudo add-apt-repository ppa:openjdk-r/ppa

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y apt-transport-https \
                        git \
                        redis-server \
                        memcached \
                        imagemagick \
                        nodejs \
                        libpq-dev \
                        zlib1g-dev \
                        postgresql-9.4 \
                        elasticsearch \
                        openjdk-8-jre-headless \
                        ruby2.4 \
                        ruby2.4-dev

echo "ES_JAVA_OPTS='-Xms128m -Xmx1g'" | sudo tee -a /etc/default/elasticsearch
sudo service elasticsearch start

sudo su postgres -c "createuser -d -R -S $USER"

gem sources --add https://ruby.taobao.org/ --remove https://rubygems.org/

sudo gem install bundler
bundle config mirror.https://rubygems.org https://ruby.taobao.org
