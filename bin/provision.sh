sudo update-locale LC_ALL="en_US.utf8"

# Add mongodb sources
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/mongodb.list

# Add Ruby sources
sudo apt-add-repository -y ppa:brightbox/ruby-ng

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y git redis-server memcached imagemagick mongodb-10gen ruby2.2 ruby2.2-dev nodejs

gem sources --add https://gems.ruby-china.org --remove https://rubygems.org/

sudo gem install bundler
bundle config mirror.https://rubygems.org https://gems.ruby-china.org
