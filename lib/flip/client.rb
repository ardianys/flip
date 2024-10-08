# Flip HTTP Client

require "base64"
require 'uri'
require 'excon'

class Flip
  module Client

    # If you using Rails then it will call ActiveSupport::JSON.encode
    # Otherwise JSON.pretty_generate
    def self._json_encode(params)
      if defined?(ActiveSupport) && defined?(ActiveSupport::JSON)
        ActiveSupport::JSON.encode(params)
      else
        require 'json' unless defined?(JSON)
        JSON.pretty_generate(params)
      end
    end

    def _json_encode(params)
      Flip::Client._json_encode(params)
    end

    # If you using Rails then it will call ActiveSupport::JSON.decode
    # Otherwise JSON.parse
    def self._json_decode(params)
      if defined?(ActiveSupport) && defined?(ActiveSupport::JSON)
        ActiveSupport::JSON.decode(params)
      else
        require 'json' unless defined?(JSON)
        JSON.parse(params)
      end
    end

    # This is proxy method for make_request to save request and response to logfile
    def request_with_logging(method, url, params)
      short_url = url.sub(config.base_url_v2, '')
      file_logger.info("Perform #{short_url} \nSending: " + _json_encode(params))
      result = make_request(method, url, params)

      if result.status_code < 300
        file_logger.info("Success #{short_url} \nGot: " + _json_encode(result.data) + "\n")
      else
        file_logger.warn("Failed #{short_url} \nGot: " + _json_encode(result.data) + "\n")
      end

      result
    end

    private

    def basic_auth_header(secret_key = SERVER_KEY)
      key = Base64.strict_encode64(secret_key + ":")
      "Basic #{key}"
    end

    def get(url, params = {})
      make_request(:get, url, params)
    end

    def delete(url, params)
      make_request(:delete, url, params)
    end

    def post(url, params)
      make_request(:post, url, params)
    end

    def patch(url, params)
      make_request(:patch, url, params)
    end

    def make_request(method, url, params, auth_header = nil)
      if !config.secret_key || config.secret_key == ''
        raise "Please configure your server key"
      end

      if !config.valid_token || config.valid_token == ''
        raise "Please configure your valid_token key"
      end

      method = method.to_s.upcase
      logger.info "Flip: #{method} #{url} #{_json_encode(params)}"
      #logger.info "Flip: Using server key: #{config.secret_key}"
      #puts "Flip: #{method} #{url} #{_json_encode(params)}"

      default_options = config.http_options || {}

      idempotency_key = config.idempotency_key
      append_notif_url = config.append_notif_url
      override_notif_url = config.override_notif_url

      # Add authentication and content type
      # Docs https://api-docs.flip.com/#http-s-header
      request_options = {
        :path => URI.parse(url).path,
        :headers => {
          "Authorization" => auth_header || basic_auth_header(config.secret_key),
          "Accept" => "application/json",
          "Content-Type" => "application/json",
          # "User-Agent" => "Flip ruby gem #{Flip::VERSION}",
          "idempotency-key" => "#{idempotency_key}",
          # "X-Append-Notification" => "#{append_notif_url}",
          # "X-Override-Notification" => "#{override_notif_url}"
        }
      }

      if method == "GET"
        request_options[:query] = URI.encode_www_form(params)
      else
        request_options[:body] = _json_encode(params)
      end

      connection_options = {
        read_timeout: 120,
        write_timeout: 120,
        connect_timeout: 120
      }.merge(default_options)

      s_time = Time.now
      request = Excon.new(url, connection_options)

      response = request.send(method.downcase.to_sym, request_options)

      if defined?(response.body)
        response_body = JSON.parse(response.body)
        if response_body.is_a?(Hash) && response_body.has_key?('status_code')
          status_code = Integer(response_body["status_code"])
          if status_code >= 400 && status_code != 407
            raise FlipError.new(
              "Flip API is returning API error. HTTP status code: #{status_code} API response: #{response_body}",
              "#{status_code}",
              "#{response_body}",
              "#{response}")
          end
        end
      end

      if response.status >= 400
        raise FlipError.new(
          "Flip API is returning API error. HTTP status code: #{response.status}  API response: #{response.body}",
          "#{response.status}",
          "#{response.body}",
          "#{response}")
      end

      logger.info "Flip: got #{(Time.now - s_time).round(3)} sec #{response.status} #{response.body}"

      Result.new(response, url, request_options, Time.now - s_time)

    rescue Excon::Errors::SocketError => error
      logger.info "Flip: socket error, can not connect (#{error.message})"
      error_response = Excon::Response.new(
        body: '{"status_code": "500", "status_message": "Internal server error, no response from backend. Try again later"}',
        status: '500'
      )
      Flip::Result.new(error_response, url, request_options, Time.now - s_time)
    end

  end
end
