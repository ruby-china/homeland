This is source code of [Ruby China Group](http://ruby-china.org)

## Install

* The system runs on *ruby 1.9.2* or *ruby 1.9.3*
* Install and start *Redis*, *MongoDb* and *Memcached*

    ```
    cp config/config.yml.default config/config.yml
    cp config/mongoid.yml.default config/mongoid.yml
    cp config/redis.yml.default config/redis.yml
    bundle
    rake db:setup
    ```

* To run it in development mode, simply use the normal `rails s`, to run it in production mode:

    ```
    rake assets:precompile
    thin start -O -C config/thin.yml
    ./script/resque start
    ```

## Deploy 

    cap deploy

## Credits

* [Contributors](https://github.com/huacnlee/ruby-china/contributors)
* Thanks [Twitter Bootstrap](http://twitter.github.com/bootstrap)
* Forked from [Homeland Project](http://github.com/huacnlee/homeland)
