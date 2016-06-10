require 'open-uri'
require 'zlib'
require 'rsync'

module JDict
  class Downloader
    def retrieve_file(url)
      filename = File.basename(url)
      File.write(filename, open(url).read)
    end

    def gunzip(filename)
      to_write = File.basename(filename, ".gz")

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
