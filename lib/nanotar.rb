module TarCommand
  class TarCommandError < Exception
  end

  class << self
    def create(output_file_name, *input_file_names)
      assert_file_not_exists(output_file_name)
      assert_files_exist(*input_file_names)
      assert_source_files(input_file_names)
      TarFile.create(output_file_name, input_file_names)
    end

    def append(output_file_name, *input_file_names)
      assert_files_exist(output_file_name, *input_file_names)
      assert_source_files(input_file_names)
      TarFile.create(output_file_name, input_file_names)
    end

    def extract(tar_file_name, dir = nil)
      assert_files_exist(tar_file_name)
      assert_directory_exist(dir) if dir
      TarFile.new(tar_file_name).extract(dir)
    end

    def list(tar_file_name)
      assert_files_exist(tar_file_name)
      TarFile.new(tar_file_name).list
    end

    private

    def assert_files_exist(*files)
      files.each do |path|
        raise TarCommandError.new("File not found '#{path}'") unless File.exists?(path)
      end
    end

    def assert_directory_exist(dir)
      raise TarCommandError.new("Directory not found '#{dir}'") unless Dir.exists?(dir)
    end

    def assert_source_files(files)
      raise TarCommandError.new("At least one source file required") unless files.any?
    end

    def assert_file_not_exists(file)
      raise TarCommandError.new("Tar file '#{file}' already exists") if File.exists?(file)
    end
  end
end

class TarFile
  BUFFER_SIZE = 8 * 1024

  def initialize(tar_path, files_to_append = nil)
    if File.exists? tar_path
      @file = File.open(tar_path, 'rb+')
    else
      @file = File.open(tar_path, 'wb+')
    end

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

  def list
    res = []
    @file.seek(0)
    while buffer = @file.read(16)
      path_size, file_size = buffer.unpack('qq')
      res << { name: @file.read(path_size), size: file_size }
      @file.seek(file_size, IO::SEEK_CUR)
    end
    res
  end

  def read_file(file_name)
    raise 'Not implemented'
  end
end