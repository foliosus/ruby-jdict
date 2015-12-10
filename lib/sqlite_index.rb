module JDict
  class AmalgaliteIndex < Index
    def initialize(path)
      @index = Amalgalite::Database.new(path + "/fts5.db")

      schema = @index.schema
      unless schema.tables['search']
        puts "Create schema"
        @index.execute_batch <<-SQL
        CREATE VIRTUAL TABLE search USING fts5(
            kanji,
            kana
        );
        SQL
        @index.reload_schema!
      end
    end

    def begin_index
      puts "===START==="
      @index.transaction
    end

    def end_index(i)
      puts "===END==="
    end
    
    def add_entry(index, entry)
      insert_data  = {
        ':kanji'   => entry.kanji,
        ':kana' => entry.kana
      }
      p insert_data

      index.prepare("INSERT INTO search( kanji, kana ) VALUES( :kanji, :kana );") do |stmt|
        stmt.execute( insert_data )
      end
    end
    
    def search_entries(query)
      @index.execute( "SELECT kanji FROM search WHERE search MATCH 'content:#{query}'" ) do |row|
        yield row["kanji"], 0.0
      end
    end

    def size
    end
  end
end
