# memcache [![Build Status](https://travis-ci.org/ifduyue/crystal-memcache.svg?branch=master)](https://travis-ci.org/ifduyue/crystal-memcache)

Memcache client written for crystal, talking text protocol

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     memcache:
       github: ifduyue/memcache
   ```

2. Run `shards install`

## Usage

```crystal
require "memcache"

client = Memcache::Client.new
client.set("key", "value")
puts client.get("key") # "value"
```

## Contributing

1. Fork it (<https://github.com/ifduyue/memcache/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Yue Du](https://github.com/ifduyue) - creator and maintainer
