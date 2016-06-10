# Ruby-JDict
Ruby gem for accessing Jim Breen's Japanese dictionaries. Can currently access the following:
  * JMdict (Japanese-English dictionary)

*Note*: For the moment, uses SQLite (via [amalgalite](https://github.com/copiousfreetime/amalgalite)) for data storage. Not intended to be scalable.

## Install
```
gem install ruby-jdict
```

## Usage
See [this](https://github.com/Ruin0x11/ruby-jdict/blob/master/examples/query.rb) example for basic usage.

If the dictionary file is not found, you will be prompted to download it.
