update-locale LC_ALL="en_US.utf8"

# Add mongodb sources
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | tee /etc/apt/sources.list.d/mongodb.list

# Add Ruby sources
sudo apt-add-repository ppa:brightbox/ruby-ng

apt-get update
apt-get install -y git redis-server memcached imagemagick mongodb-10gen ruby2.2 ruby2.2-dev nodejs

gem install bundler