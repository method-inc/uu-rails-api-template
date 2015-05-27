# Rails Application Template for a Rails API based app

This template removes the Railties and gems that don't make sense for an 
API-only application. It also adds the following gems:

* Rspec, Guard, Pry (byebug), SimpleCov
* Puma
* roar-rails

The template will generate the Rspec files and initialize guard.  

## Docker
A `Dockerfile` and `docker-compose.yml` are included in the generated app.

## How to Use

    rails new service_name -m <path-to>/rails-api-template.rb

Once the app exists

    cd service_name

And then you can:

    guard

or 

    docker-compose up

And you should be good to go. (Presuming you have boot2docker or docker installed)

## Gotchas

* You'll need to clone this repository to use it, since I decided to use local files to copy over. This could be fixed by included the file content in the template.
