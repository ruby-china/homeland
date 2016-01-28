sudo update-locale LC_ALL="en_US.utf8"

# Add mongodb sources
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/mongodb.list

# Add Elasticsearch sources
wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb http://packages.elastic.co/elasticsearch/2.x/debian stable main" | sudo tee -a /etc/apt/sources.list.d/elasticsearch-2.x.list

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y git \
                        redis-server \
                        memcached \
                        imagemagick \
                        mongodb-10gen \
                        nodejs \
                        elasticsearch \
                        openjdk-7-jre-headless

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
