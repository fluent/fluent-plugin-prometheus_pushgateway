require 'fluent/plugin/out_prometheus_pushgateway'
require 'fluent/test/driver/output'

RSpec.describe Fluent::Plugin::PrometheusPushgatewayOutput do
  describe '#configure' do
    it 'creates successfully' do
      config = %[
          @type prometheus_pushgateway
          job_name name
        ]
      driver = Fluent::Test::Driver::Output.new(described_class)
      expect { driver.configure(config) }.not_to raise_error
    end

    it 'raises an error when job name does not exist' do
      config = '@type prometheus_pushgateway'
      driver = Fluent::Test::Driver::Output.new(described_class)
      expect { driver.configure(config) }.to raise_error(Fluent::ConfigError)
    end

    context 'when endpoint is HTTPS' do
      it 'returns default parameters' do
        config = %[
          @type prometheus_pushgateway
          gateway https://127.0.0.1
          job_name name
        ]

        driver = Fluent::Test::Driver::Output.new(described_class)
        expect(driver.instance).to receive(:tls_options).and_wrap_original do |v|
          r = v.call
          expect(r).to eq({ verify_mode: OpenSSL::SSL::VERIFY_PEER, ciphers: 'ALL:!aNULL:!eNULL:!SSLv2', ssl_version: :TLSv1_2 })
          r
        end

        expect { driver.configure(config) }.not_to raise_error
      end

      it 'sets verify_mode' do
        config = %[
          @type prometheus_pushgateway
          gateway https://127.0.0.1
          job_name name
          tls_verify_mode none
        ]

        driver = Fluent::Test::Driver::Output.new(described_class)
        expect(driver.instance).to receive(:tls_options).and_wrap_original do |v|
          r = v.call
          expect(r).to eq({ verify_mode: OpenSSL::SSL::VERIFY_NONE, ciphers: 'ALL:!aNULL:!eNULL:!SSLv2', ssl_version: :TLSv1_2 })
          r
        end

        expect { driver.configure(config) }.not_to raise_error
      end

      it 'raises an ConfigError when tls_ca_cert_path is wrong' do
        config = %[
          @type prometheus_pushgateway
          gateway https://127.0.0.1
          job_name name
          tls_ca_cert_path invalid
        ]

        driver = Fluent::Test::Driver::Output.new(described_class)
        expect { driver.configure(config) }.to raise_error(Fluent::ConfigError, /tls_ca_cert_path is wrong/)
      end

      it 'raises an ConfigError when tls_client_cert_path is wrong' do
        config = %[
          @type prometheus_pushgateway
          gateway https://127.0.0.1
          job_name name
          tls_client_cert_path invalid
        ]

        driver = Fluent::Test::Driver::Output.new(described_class)
        expect { driver.configure(config) }.to raise_error(Fluent::ConfigError, /tls_client_cert_path is wrong/)
      end

      it 'raises an ConfigError when tls_private_key_path is wrong' do
        config = %[
          @type prometheus_pushgateway
          gateway https://127.0.0.1
          job_name name
          tls_private_key_path invalid
        ]

        driver = Fluent::Test::Driver::Output.new(described_class)
        expect { driver.configure(config) }.to raise_error(Fluent::ConfigError, /tls_private_key_path is wrong/)
      end
    end
  end
end
