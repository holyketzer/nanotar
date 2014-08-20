require 'test/unit'
require 'nanotar'

class NanotarTest < Test::Unit::TestCase
  SRC_FILES = ['a.txt', 'b.txt'].map { |name| File.join('fixtures', name) }
  EXTRACT_DIR = 'tmp'
  TAR_FILE = File.join(EXTRACT_DIR, 'test.tar')


  def setup
    Dir.chdir('test')
    Dir.mkdir(EXTRACT_DIR) unless Dir.exists?(EXTRACT_DIR)
  end

  def teardown
    `rm #{EXTRACT_DIR}/*`
  ensure
    Dir.chdir('..')
  end

  def test_create
    TarFile.create(TAR_FILE, SRC_FILES)

    assert File.exists?(TAR_FILE), 'Tar should be created'
    assert File.size(TAR_FILE) > SRC_FILES.map { |f| File.size(f) }.reduce(:+), 'Size of the tar file should be greater than sum of source files sizes'
  end

  def test_extract
    tar = TarFile.create(TAR_FILE, SRC_FILES)
    tar.extract(EXTRACT_DIR)

    files = SRC_FILES.map { |f| {
        source: f,
        extracted: File.join(EXTRACT_DIR, File.basename(f))
    }}

    files.each do |f|
      assert File.exists?(f[:extracted]), "File #{f} should be extracted"
      assert_equal File.size(f[:source]), File.size(f[:extracted]), "File size should be equal for both versions of file #{f}"

      byte = 0
      File.open(f[:source], 'rb') do |source|
        File.open(f[:extracted], 'rb') do |extracted|
          assert_equal source.read(1), extracted.read(1), "Byte ##{byte} should be equal for both versions of file #{f}"
          byte += 1
        end
      end
    end
  end

  def test_list
    tar = TarFile.create(TAR_FILE, SRC_FILES)
    expected = SRC_FILES.map { |f| {
      name: File.basename(f),
      size: File.size(f)
    }}

    assert_equal expected, tar.list, 'Tar list should return list of files with size'
  end

  def test_append
    first_src, *other_src = SRC_FILES

    tar = TarFile.create(TAR_FILE, first_src)
    assert_equal 1, tar.list.size

    tar.append(other_src)
    assert_equal SRC_FILES.size, tar.list.size
  end
end