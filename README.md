# EasyMapper

Simple ORM library for ruby. This project is part of a ruby course in Faculty of Mathematics and Informatics in Sofia University.

[ORM Library Project Task](https://github.com/fmi/ruby-course-projects/blob/master/sample_projects/orm.md)


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'easy_mapper'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install easy_mapper

## Usage


## Development

After checking out the repo, run `bin/setup` to install dependencies. 

To run the tests you need to install `postgresql` and create a test database. Open `bin/postgre_scripts.sql` to find the queries to create the needed tables for the tests. Open `east_mapper_spec.rb` and enter the configuration for your database. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ViktorMarinov/easy_mapper.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
