
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
  gem 'prmd'
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

create_file 'schema/meta.json' do <<-EOF
{
"description": "Ervice",
"id":"service-uu",
"links": [{
"href" : "https://api.esalrugs.com",
"rel" : "self"
}],
"title" : "UU Service"
}
EOF
end

empty_directory "schema/schemata"

rakefile("schema.rake") do <<-EOF
require 'prmd/rake_tasks/combine'
require 'prmd/rake_tasks/verify'
require 'prmd/rake_tasks/doc'

namespace :schema do
    Prmd::RakeTasks::Combine.new do |t|
      t.options[:meta] = 'schema/meta.json'    
      # use meta.yml if you prefer YAML format
      t.paths << 'schema/schemata'
      t.output_file = 'schema/api.json'
    end

    Prmd::RakeTasks::Verify.new do |t|
      t.files << 'schema/api.json'
    end

    Prmd::RakeTasks::Doc.new do |t|
      t.files = { 'schema/api.json' => 'schema/api.md' }
    end
  task default: ['schema:combine', 'schema:verify', 'schema:doc']
end
EOF
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

