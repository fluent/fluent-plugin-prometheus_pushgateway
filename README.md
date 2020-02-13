# Fluent::Plugin::PrometheusPushgateway

Please read [fluent-plugin-prometheus](https://github.com/fluent/fluent-plugin-prometheus) first since fluent-plugin-prometheus_pushgateway gem depends on it.

This is Fluentd's plugin for sending data collected by fluent-plugin-prometheus plugin to [Pushgateway](https://github.com/prometheus/pushgateway).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fluent-plugin-prometheus_pushgateway'
```

And then execute:

```
$ bundle install
```

Or install it yourself as:

```
$ gem install fluent-plugin-prometheus_pushgateway
```

## Usage

**See also [fluent-plugin-prometheus](https://github.com/fluent/fluent-plugin-prometheus)**.

```
<match>
  @type prometheus_pushgateway
  job_name fluentd_prometheus_pushgateway
</match>
```

More configuration parameters:

- `gateway`: binding interface (default: 'http://localhost:9091')
- `job_name`: job name. this value must be a unique (required)
- `instance`: instance name (default: nil)
- `push_interval`: the interval of pushing data to pushgateway (default: 3)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `fluent-plugin-prometheus_pushgateway.gemspec`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fluent/fluent-plugin-prometheus_pushgateway.

