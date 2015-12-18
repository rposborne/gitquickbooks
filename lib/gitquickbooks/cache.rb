module GitQuickBooks
  ##
  # Setup Marshalling cache
  class Cache
    # attr_accesor :base_path
    def load(name)
      Marshal.load(IO.read("tmp/#{name}"))
    end

    def present?(name)
      File.file?("tmp/#{name}")
    end

    def write(name, data)
      File.open("tmp/#{name}", 'w+') do |f|
        f.write(Marshal.dump(data))
      end
    end

    def delete(name)
      File.delete("tmp/#{name}")
    end

    def fetch(name, &block)
      if !present?(name)
        @data = block.call
        write(name, @data)
        @data
      else
        puts "#{name} extracted from cache".red
        @data = GitQuickBooks::Cache.new.load(name)
      end
    end
  end
end
