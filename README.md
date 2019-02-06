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

## Issues
* The code for inserting Entry objects into the database is horrible. Should create multiple tables for each datatype instead of a single table for all datatypes.
* Some routines need to be generalized to allow for the usage of dictionaries besides JMDict (like Tatoeba or KANJIDIC).
* Many functions are getting too large/unreadable.
