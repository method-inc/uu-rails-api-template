# Rails Application Template for a Rails API based app

This template removes the Railties and gems that don't make sense for an 
API-only application. It also adds the following gems:

* Rspec, Guard, Pry (byebug), SimpleCov, Mutant
* Puma
* roar-rails

The template will generate the Rspec files and initialize guard.  

## Docker
A `Dockerfile` and `docker-compose.yml` are included in the generated app.

## How to Use

    rails new service_name -m <path-to>/rails-api-template.rb

or 

    rails-api new service_name -m <path-to>/rails-api-template.rb

Once the app exists

    cd service_name

And then you can:

    guard

or 

    docker-compose up
    docker-compose run api rake db:create # The first time

And you should be good to go. (Presuming you have boot2docker or docker installed)

## JSON Schema and API Docs
The [`prmd`](https://github.com/interagent/prmd) is included in the dev environment. It is used to help create JSON Schema for the API. This schema is then used to validate JSON sent to/from the API, as well as generate docs.

Add the .yml files for each API resource into schema/schemata, then call `rake schema:combine`. To generate markdown, `rake schema:doc`

The template also adds the [`committee`](https://github.com/interagent/committee) gem along with middleware provided by that gem to validate JSON schema against the generated JSON schema file.

## Routes
This template adds a `/heath`  route that points to `health#index`. This is the health check endpoint that should make sure dependent servics are responding, etc. It's also known as a [canary endpoint](http://byterot.blogspot.com/2014/11/health-endpoint-in-api-design-slippery-rest-api-design-canary-endpoint-hysterix-asp-net-web-api.html). It should return JSON and be secured with an API token.

## Mutant Testing
The [mutant](https://github.com/mbj/mutant) is included to enable mutation testing. 

## Gotchas

* You'll need to clone this repository to use it, since I decided to use local files to copy over. This could be fixed by included the file content in the template.

## TODO
* Document mutation testing command/flow
