require 'yaml'
require 'excon'
require 'erb'

class Flip

  class Config

    def initialize(options = nil)
      @base_url_v2 = "https://bigflip.id/api/v2"
      @base_url_v3 = "https://bigflip.id/api/v3"
      @base_url_kyc = "https://api.flip.id/kyc/api/v1"

      if @envi == "staging"
        @base_url_v2 = "https://bigflip.id/big_sandbox_api/v2"
        @base_url_v3 = "https://bigflip.id/big_sandbox_api/v3"
        @base_url_kyc = "https://api.flip.id/kyc-sandbox/api/v1"
      end

      # DEBUG
      # message = "FLIP gem initialize env yg dipakai `envi-#{@envi}` `base_url_v2-#{@base_url_v2}` `@secret_key-#{@secret_key}` `@valid_token-#{@valid_token}`"
      # NotifyDevJob.perform_later message

      apply(options) if options
    end

    def envi=(value)
      @envi = value
    end

    def base_url_v3=(value)
      @base_url_v3 = value
    end

    def base_url_v3
      @base_url_v3
    end

    def base_url_v2=(value)
      @base_url_v2 = value
    end

    def base_url_v2
      @base_url_v2
    end

    def envi
      @envi
    end

    def secret_key=(value)
      @secret_key = value
    end

    def secret_key
      @secret_key
    end

    def valid_token=(value)
      @valid_token = value
    end

    def valid_token
      @valid_token
    end

    def http_options=(options)
      unless options.is_a?(Hash)
        raise ArgumentError, "http_options should be a hash"
      end

      diff = options.keys.map(&:to_sym) - Excon::VALID_CONNECTION_KEYS
      if diff.size > 0
        raise ArgumentError,
              "http_options contain unsupported keys: #{diff.inspect}\n" +
                "Supported keys are: #{Excon::VALID_CONNECTION_KEYS.inspect}"
      end

      @http_options = options
    end

    def idempotency_key=(value)
      @idempotency_key = value
    end

    def idempotency_key
      @idempotency_key
    end

    def append_notif_url=(value)
      @append_notif_url = value
    end

    def append_notif_url
      @append_notif_url
    end

    def override_notif_url=(value)
      @override_notif_url = value
    end

    def override_notif_url
      @override_notif_url
    end

    def http_options
      @http_options
    end

    def load_config(filename, yml_section = nil)
      yml_file, file_yml_section = filename.to_s.split('#')
      config_data = YAML.load(ERB.new(File.read(yml_file)).result)

      yml_section ||= file_yml_section
      if defined?(Rails) && !yml_section
        yml_section = Rails.env.to_s
      end

      if yml_section && !config_data.has_key?(yml_section)
        STDERR.puts "Flip: Can not find section #{yml_section.inspect} in file #{yml_file}"
        STDERR.puts "           Available sections: #{config_data.keys}"

        if config_data['development'] && config_data['development']['secret_key']
          new_section = 'development'
        end

        first_key = config_data.keys.first
        if config_data[first_key]['secret_key']
          new_section = first_key
        end

        if new_section
          STDERR.puts "Flip: Using first section #{new_section.inspect}"
          yml_section = new_section
        end
      end

      apply(yml_section ? config_data[yml_section] : config_data)
    end

    alias :load_yml :load_config

    def inspect
      "<Flip::Config " +
        "@secret_key=#{@secret_key.inspect} " +
        "@envi=#{@envi.inspect} " +
        "@valid_token=#{@valid_token.inspect} " +
        "@http_options=#{@http_options.inspect}>"
    end

    private


    AVAILABLE_KEYS = [:secret_key, :envi, :valid_token, :http_options]
    def apply(hash)
      hash.each do |key, value|
        unless AVAILABLE_KEYS.include?(key.to_s.to_sym)
          raise ArgumentError, "Unknown option #{key.inspect}, available keys: #{AVAILABLE_KEYS.map(&:inspect).join(", ")}"
        end
        send(:"#{key}=", value)
      end
    end
  end

end