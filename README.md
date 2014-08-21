nanotar
=======

Simple tar command tool implementation

# Installation

```
git clone https://github.com/holyketzer/nanotar.git
cd nanotar
gem build nanotar.gemspec
gem install nanotar-1.0.0.gem
```

or

```
gem 'nanotar', git: 'git://github.com/holyketzer/nanotar.git'
bundle install
```

# Usage

Get help
```
nanotar -h
```

Creating tar
```
nanotar -c new_tar_file.tar source_file1 source_file2
```

Append existing tar
```
nanotar -a existing_tar_file.tar source_file1 source_file2
```

Extract files from tar
```
nanotar -x existing_tar_file.tar [-d extract_dir]
```

List files inside tar
```
nanotar -l existing_tar_file.tar
```

# Run tests

```
bundle install
bundle exec rake test
```
