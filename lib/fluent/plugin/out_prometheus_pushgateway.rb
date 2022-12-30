#
# Fluentd
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#

require 'prometheus/client/push'
require 'prometheus/client/version'
require 'fluent/plugin/output'

begin
  require 'fluent/tls'
rescue LoadError
  # compatible layer for fluentd v1.9.1 or earlier
  # https://github.com/fluent/fluentd/pull/2802
  require_relative 'prometheus_pushgateway/tls'
end

module Fluent
  module Plugin
    class PrometheusPushgatewayOutput < Fluent::Plugin::Output
      Fluent::Plugin.register_output('prometheus_pushgateway', self)

      helpers :timer

      desc 'The endpoint of pushgateway'
      config_param :gateway, :string, default: 'http://localhost:9091'
      desc 'job name. this value must be unique between instances'
      config_param :job_name, :string
      desc 'instance name'
      config_param :instance, :string, default: nil
      desc 'the interval of pushing data to pushgateway'
      config_param :push_interval, :time, default: 3

      desc 'The CA certificate path for TLS'
      config_param :tls_ca_cert_path, :string, default: nil
      desc 'The client certificate path for TLS'
      config_param :tls_client_cert_path, :string, default: nil
      desc 'The client private key path for TLS'
      config_param :tls_private_key_path, :string, default: nil
      desc 'The client private key passphrase for TLS'
      config_param :tls_private_key_passphrase, :string, default: nil, secret: true
      desc 'The verify mode of TLS'
      config_param :tls_verify_mode, :enum, list: %i[none peer], default: :peer
      desc 'The default version of TLS'
      config_param :tls_version, :enum, list: Fluent::TLS::SUPPORTED_VERSIONS, default: Fluent::TLS::DEFAULT_VERSION
      desc 'The cipher configuration of TLS'
      config_param :tls_ciphers, :string, default: Fluent::TLS::CIPHERS_DEFAULT

      def initialize
        super

        @registry = ::Prometheus::Client.registry
      end

      def multi_workers_ready?
        true
      end

      def configure(conf)
        super

        if Prometheus::Client::VERSION.split(".")[0].to_i > 3
          grouping_key = @instance ? {instance: @instance} : {}
          @push_client = ::Prometheus::Client::Push.new(job: "#{@job_name}:#{fluentd_worker_id}", grouping_key: grouping_key, gateway: @gateway)
        else
          @push_client = ::Prometheus::Client::Push.new("#{@job_name}:#{fluentd_worker_id}", @instance, @gateway)
        end

        use_tls = gateway && (URI.parse(gateway).scheme == 'https')

        if use_tls
          # prometheus client doesn't have an interface to set the HTTPS options
          http = @push_client.instance_variable_get(:@http)
          if http.nil?
            log.warn("prometheus client ruby's version unmatched. https setting is ignored")
          end

          # https://github.com/ruby/ruby/blob/dec802d8b59900e57e18fa6712caf95f12324aea/lib/net/http.rb#L599-L604
          tls_options.each do |k, v|
            http.__send__("#{k}=", v)
          end
        end
      end

      def start
        super

        timer_execute(:out_prometheus_pushgateway, @push_interval) do
          @push_client.add(@registry)
        end
      end

      def process(tag, es)
        # nothing
      end

      private

      def tls_options
        opt = {}

        if @tls_ca_cert_path
          unless File.file?(@tls_ca_cert_path)
            raise Fluent::ConfigError, "tls_ca_cert_path is wrong: #{@tls_ca_cert_path}"
          end

          opt[:ca_file] = @tls_ca_cert_path
        end

        if @tls_client_cert_path
          unless File.file?(@tls_client_cert_path)
            raise Fluent::ConfigError, "tls_client_cert_path is wrong: #{@tls_client_cert_path}"
          end

          opt[:cert] = OpenSSL::X509::Certificate.new(File.read(@tls_client_cert_path))
        end

        if @tls_private_key_path
          unless File.file?(@tls_private_key_path)
            raise Fluent::ConfigError, "tls_private_key_path is wrong: #{@tls_private_key_path}"
          end

          opt[:key] = OpenSSL::PKey.read(File.read(@tls_private_key_path), @tls_private_key_passphrase)
        end

        opt[:verify_mode] = case @tls_verify_mode
                            when :none
                              OpenSSL::SSL::VERIFY_NONE
                            when :peer
                              OpenSSL::SSL::VERIFY_PEER
                            end

        opt[:ciphers] = @tls_ciphers
        opt[:ssl_version] = @tls_version

        opt
      end
    end
  end
end
