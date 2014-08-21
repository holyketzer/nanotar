Gem::Specification.new do |s|
  s.name        = 'nanotar'
  s.version     = '1.0.0'
  s.executables << 'nanotar'
  s.date        = '2014-08-19'
  s.summary     = 'Tar utility'
  s.description = 'A simple tar utility'
  s.authors     = ['Alex Emelyanov']
  s.email       = 'holyketzer@gmail.com'
  s.files       = ['lib/nanotar.rb']
  s.homepage    = 'https://github.com/holyketzer/nanotar'
  s.license     = 'BSD'

  s.add_runtime_dependency 'slop', '~> 3.6'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'minitest', '~> 4.0'
end