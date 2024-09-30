require 'flip/version'
require 'flip/config'
require 'flip/client'
require 'flip/api'
require 'flip/result'
require 'flip/flip_error'

if defined?(::Rails)
  require 'flip/events'
end

class Flip
  include Flip::Client
  include Flip::Api

  autoload :Events,     'flip/events'

  class << self
    extend Forwardable

    def_delegators :instance, :logger, :logger=, :config, :setup, :file_logger, :file_logger=
    def_delegators :instance, :request_with_logging, :basic_auth_header, :get, :post, :delete, :make_request, :patch
    def_delegators :instance, :bank_info, :balance, :create_link, :disbursement, :get_disbursement, :get_disbursements, :bank_account_inquiry

    # Shortcut for Flip::Events
    def events
      Flip::Events if defined?(Flip::Events)
    end

    # More safe json parser
    def decode_notification_json(input)
      return Flip::Client._json_decode(input)
    end

    def instance
      @instance ||= new
    end

  end

  def events
    self.class.events
  end

  def initialize(options = nil)
    if options && options[:logger]
      self.logger = options.delete(:logger)
      options.delete("logger")
    end

    if options && options[:file_logger]
      self.file_logger = options.delete(:file_logger)
      options.delete("file_logger")
    end

    if options
      @config = Flip::Config.new(options)
    end
  end

  def config(&block)
    if block
      instance_eval(&block)
    else
      @config ||= Flip::Config.new
    end
  end
  alias_method :setup, :config

  def checksum(params)
    require 'digest' unless defined?(Digest)

    params_sym = {}
    params.each do |key, value|
      params_sym[key.to_sym] = value
    end

    if (config.secret_key.nil? || config.secret_key == "") && params_sym[:secret_key].nil?
      raise ArgumentError, "Server key is required. Please set Flip.config.secret_key or :secret_key key"
    end

    required = [:order_id, :status_code, :gross_amount]
    missing = required - params_sym.keys.select {|k| !!params_sym[k] }
    if missing.size > 0
      raise ArgumentError, "Missing required parameters: #{missing.map(&:inspect).join(", ")}"
    end

    if params_sym[:gross_amount].is_a?(Numeric)
      params_sym[:gross_amount] = "%0.2f" % params_sym[:gross_amount]
    elsif params_sym[:gross_amount].is_a?(String) && params_sym[:gross_amount] !~ /\d+\.\d\d$/
      raise ArgumentError, %{gross_amount has invalid format, should be a number or string with cents e.g "52.00" (given: #{params_sym[:gross_amount].inspect})}
    end

    seed = "#{params_sym[:order_id]}#{params_sym[:status_code]}" +
           "#{params_sym[:gross_amount]}#{params_sym[:secret_key] || config.secret_key}"

    logger.debug("checksum source: #{seed}")

    Digest::SHA2.new(512).hexdigest(seed)
  end

  def logger
    return @logger if @logger
    if defined?(Rails)
      Rails.logger
    else
      unless @log
        require 'logger'
        @log = Logger.new(STDOUT)
        @log.level = Logger::INFO
      end
      @log
    end
  end

  def logger=(value)
    @logger = value
  end

  def file_logger
    if !@file_logger
      require 'logger'
      begin
        if defined?(Rails) && Rails.root
          require 'fileutils'
          FileUtils.mkdir_p(Rails.root.join("log"))
          @file_logger = Logger.new(Rails.root.join("log/flip.log").to_s)
        else
          @file_logger = Logger.new("/dev/null")
        end
      rescue => error
        STDERR.puts "Failed to create Flip.file_logger, will use /dev/null"
        STDERR.puts "#{error.class}: #{error.message}"
        STDERR.puts error.backtrace
        @file_logger = Logger.new("/dev/null")
      end
    end

    @file_logger
  end

  def file_logger=(value)
    @file_logger = value
  end
end