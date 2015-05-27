
def source_paths
  Array(super) + 
    [File.expand_path(File.dirname(__FILE__))]
end

remove_file "Gemfile"
run "touch Gemfile"
add_source 'https://rubygems.org'
gem 'rails', '4.2.1'
gem 'rails-api'
gem 'puma'

gem 'pg'
gem 'roar-rails'

gem_group :development, :test do
  gem 'spring'
  gem 'pry-rails'
  gem 'web-console', '~> 2.0'
end

gem_group :test do
  gem 'rspec-rails', require: false
  gem 'simplecov', require: false
  gem 'simplecov-rcov', :require => false
  gem 'guard-rspec'
  gem 'mutant'
  gem 'mutant-rspec'
end

copy_file "Dockerfile"
copy_file "docker-compose.yml"
remove_file ".gitignore"
copy_file ".gitignore"

inside 'config' do
  remove_file 'database.yml'
  copy_file 'database.yml'
end

after_bundle do
  remove_dir "app/views"
  remove_dir "app/mailers"
  remove_dir "test"

  insert_into_file 'config/application.rb', after: "require 'rails/all'\n" do <<-RUBY
require "active_record/railtie"
require "action_controller/railtie"
RUBY
  end

  gsub_file 'config/application.rb', /require 'rails\/all'/, '# require "rails/all"'

  application do <<-RUBY
    config.assets.enabled = false
    config.generators do |g|
      g.view_specs false
      g.helper_specs false
    end
RUBY
  end

  gsub_file 'config/environments/development.rb', /action_mailer/, ''

  run "spring stop"
  generate "rspec:install"
  run "guard init"

  git :init
  git add: "."
  git commit: "-a -m 'Initial commit'"
end

