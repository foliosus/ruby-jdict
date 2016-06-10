require 'open-uri'
require 'zlib'
require 'rsync'

module JDict
  class Downloader
    def download

    end

    def sync

    end

    private

    def retrieve_file(url, dest_dir)
      filename = File.basename(url)
      full_path = File.join(dest_dir, filename)
      File.write(full_path, open(url).read)
      full_path
    end

    def gunzip(filename)
      to_write = File.join(File.dirname(filename), File.basename(filename, ".gz"))

      puts filename
      puts to_write

      File.open(to_write, 'w') do |wri|
        File.open(filename) do |f|
          gz = Zlib::GzipReader.new(f)
          wri.write(gz.read)
          gz.close
        end
      end
    end

    def rsync(src, dest)
      Rsync.run(src, dest)
    end
  end
end
