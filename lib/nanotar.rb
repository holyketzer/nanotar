module TarUtils
  # option parser, slop
  class << self
    def create(output_file_name, input_file_names)
    end

    def append(output_file_name, input_file_names)
    end

    def extract(tar_file_name)
    end
  end
end

class TarFile
  BUFFER_SIZE = 1024 * 1024

  def initialize(tar_path, files_to_append = nil)
    @file = File.open(tar_path, 'wb+')
    if files_to_append
      append(files_to_append)
    end
  end

  def self.create(tar_path, files_to_append)
    new(tar_path, files_to_append)
  end

  def self.load(tar_path)
    new(tar_path)
  end

  def append(files_to_append)
    files_to_append = [files_to_append] if files_to_append.is_a? String

    @file.seek(0, IO::SEEK_END)
    files_to_append.each do |file_path|
      input_file = File.open(file_path, 'rb')
      base_name = File.basename(input_file)
      @file.write([base_name.size, input_file.size].pack('qq'))
      @file.write(base_name)
      while buffer = input_file.read(BUFFER_SIZE)
        @file.write(buffer)
      end
    end
    @file.flush
  end

  def extract(dir = nil)
    @file.seek(0)
    while buffer = @file.read(16)
      path_size, file_size = buffer.unpack('qq')
      path = @file.read(path_size)
      path = File.join(dir, path) if dir
      File.open(path, 'wb') do |f|
        (file_size / BUFFER_SIZE).times { f.write(@file.read(BUFFER_SIZE)) }
        f.write(@file.read(file_size % BUFFER_SIZE))
      end
    end
  end

  def read_file(file_name)
    raise 'Not implemented'
  end
end