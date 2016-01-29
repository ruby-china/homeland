sudo update-locale LC_ALL="en_US.utf8"

# Add Elasticsearch sources
wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb http://packages.elastic.co/elasticsearch/2.x/debian stable main" | sudo tee -a /etc/apt/sources.list.d/elasticsearch-2.x.list

# Add PG sources
APP_DB_USER=admin
APP_DB_PASS=admin
PG_VERSION=9.4
export DEBIAN_FRONTEND=noninteractive

PG_REPO_APT_SOURCE=/etc/apt/sources.list.d/pgdg.list
if [ ! -f "$PG_REPO_APT_SOURCE" ]
then
  # Add PG apt repo:
  echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" | sudo tee -a "$PG_REPO_APT_SOURCE"

  # Add PGDG repo key:
  wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
fi

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y git \
                        redis-server \
                        memcached \
                        imagemagick \
                        nodejs \
                        libpq-dev \
                        "postgresql-$PG_VERSION" \
                        "postgresql-contrib-$PG_VERSION" \
                        elasticsearch \
                        openjdk-7-jre-headless

PG_CONF="/etc/postgresql/$PG_VERSION/main/postgresql.conf"
PG_HBA="/etc/postgresql/$PG_VERSION/main/pg_hba.conf"
PG_DIR="/var/lib/postgresql/$PG_VERSION/main"

sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" "$PG_CONF"
echo "host    all             all             all                     md5" | sudo tee -a "$PG_HBA"
echo "client_encoding = utf8" | sudo tee -a "$PG_CONF"
sudo service postgresql restart

cat << EOF | sudo su postgres -c psql
-- Create the database user:
CREATE USER "$APP_DB_USER" WITH CREATEDB PASSWORD '$APP_DB_PASS';
EOF


sudo update-rc.d elasticsearch defaults
sudo service elasticsearch start

# Insall ruby
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
\curl -sSL https://get.rvm.io | bash -s stable
source /home/vagrant/.rvm/scripts/rvm
rvm get head
rvm install 2.3

gem sources --add https://ruby.taobao.org/ --remove https://rubygems.org/

gem install bundler
bundle config mirror.https://rubygems.org https://ruby.taobao.org
