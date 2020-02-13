require 'fluent/plugin/out_prometheus_pushgateway'
require 'fluent/test/driver/output'

RSpec.describe Fluent::Plugin::PrometheusPushgatewayOutput do
  describe '#configure' do
    describe 'valid' do
      it 'creates successfully' do
        config = %[
          type prometheus_pushgateway
          job_name name
        ]
        driver = Fluent::Test::Driver::Output.new(described_class)
        expect { driver.configure(config) }.not_to raise_error
      end

      it 'raises an error when job name does not exist' do
        config = 'type prometheus_pushgateway'
        driver = Fluent::Test::Driver::Output.new(described_class)
        expect { driver.configure(config) }.to raise_error(Fluent::ConfigError)
      end
    end
  end
end
