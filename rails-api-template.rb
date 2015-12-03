require 'shellwords'
#
# Add this template directory to source_paths so that Thor actions like
# copy_file and template resolve against our source files. If this file was
# invoked remotely via HTTP, that means the files are not present locally.
# In that case, use `git clone` to download them to a local temporary dir.
# Thanks @mattbrictson!
#
def current_directory
  @current_directory ||=
    if __FILE__ =~ %r{\Ahttps?://}
      tempdir = Dir.mktmpdir("uu-rails-api-template-")
      at_exit { FileUtils.remove_entry(tempdir) }
      git :clone => [
        "--quiet",
        "https://github.com/skookum/uu-rails-api-template.git",
        tempdir
      ].map(&:shellescape).join(" ")

      tempdir
    else
      File.expand_path(File.dirname(__FILE__))
    end
end

def source_paths
  Array(super) + [current_directory]
end
#
# Add this template directory to source_paths so that Thor actions like
# copy_file and template resolve against our source files. If this file was
# invoked remotely via HTTP, that means the files are not present locally.
# In that case, use `git clone` to download them to a local temporary dir.



remove_file "Gemfile"
run "touch Gemfile"
add_source "https://rubygems.org"
gem "rails", "4.2.1"
gem "rails-api"
gem "puma"

gem "pg"
gem "roar-rails"
gem "multi_json"

gem "committee"

gem_group :development, :test do
  gem "spring"
  gem "pry-rails"
  gem "web-console", "~> 2.0"
  gem "prmd"
  gem "guard"
  gem "rspec-rails", require: false
  gem "guard-rspec"
  gem "rubocop"
  gem "rubocop-rspec"
  gem "guard-rubocop"
end

gem_group :test do
  gem "simplecov", require: false
  gem "simplecov-rcov", require: false
  gem "mutant"
  gem "mutant-rspec"
end

copy_file "Dockerfile"
copy_file "docker-compose.yml"
remove_file ".gitignore"
copy_file ".gitignore"

inside "config" do
  remove_file "database.yml"
  create_file "database.yml" do <<-EOF
default: &default
  adapter: postgresql
  host: db
  port: 5432
  pool: 5
  timeout: 5000
  user: postgres
  password: postgres

development:
  <<: *default
  database: #{app_name}_development

# Warning: The database defined as "test" will be erased and
# re-generated from your development database when you run "rake".
# Do not set this db to the same as development or production.
test:
  <<: *default
  database: #{app_name}_test
  host: 192.168.59.103

production:
  <<: *default
  database: #{app_name}_production

  EOF
  end
end

create_file "schema/meta.json" do <<-EOF
{
"description": "Service",
"id":"service-uu",
"links": [{
"href" : "https://api.esalrugs.com",
"rel" : "self"
}],
"title" : "UU Service"
}
EOF
end

# JSON Schema
empty_directory "schema/schemata"

rakefile("schema.rake") do <<-EOF
require "prmd/rake_tasks/combine"
require "prmd/rake_tasks/verify"
require "prmd/rake_tasks/doc"

namespace :schema do
    Prmd::RakeTasks::Combine.new do |t|
      t.options[:meta] = "schema/meta.json"
      # use meta.yml if you prefer YAML format
      t.paths << "schema/schemata"
      t.output_file = "schema/api.json"
    end

    Prmd::RakeTasks::Verify.new do |t|
      t.files << "schema/api.json"
    end

    Prmd::RakeTasks::Doc.new do |t|
      t.files = { "schema/api.json" => "schema/api.md" }
    end
  task default: ["schema:combine", "schema:verify", "schema:doc"]
end
EOF
end

after_bundle do
  remove_dir "app/views"
  remove_dir "app/mailers"
  remove_dir "test"

  insert_into_file "config/application.rb", after: "require \"rails/all\"\n" do <<-RUBY
require "active_record/railtie"
require "action_controller/railtie"
  RUBY
  end

  gsub_file "config/application.rb", /require "rails\/all"/, '# require "rails/all"'

  application do <<-RUBY
    config.assets.enabled = false
    config.generators do |g|
      g.test_framework :rspec, fixture: true
      g.view_specs false
      g.helper_specs false
    end

    # Validates the supplied and returned schema.
    # docs: https://github.com/interagent/committee
    config.middleware.use Committee::Middleware::RequestValidation, schema: JSON.parse(File.read("./schema/api.json")) if File.exist?("./schema/api.json")
  RUBY
  end

  gsub_file "config/environments/development.rb", /.*action_mailer.*\n/, ""
  gsub_file "config/environments/test.rb", /.*action_mailer.*\n/, ""

  gsub_file "app/controllers/application_controller.rb", /protect_from_forgery/, "# protect_from_forgery"

  run "spring stop"
  generate "rspec:install"
  remove_file "spec/spec_helper.rb"
  copy_file "spec_helper.rb", "spec/spec_helper.rb"
  remove_file "spec/rails_helper.rb"
  copy_file "rails_helper.rb", "spec/rails_helper.rb"

  run "guard init"
  remove_file "Guardfile"
  copy_file "Guardfile"
  remove_file ".rubocop.yml"
  copy_file "rubocop.yml", ".rubocop.yml"

  # Health Check route
  generate(:controller, "health index")
  route "root to: \"health#index\""

  git :init
  git add: "."
  git commit: "-a -m 'Initial commit'"
end

