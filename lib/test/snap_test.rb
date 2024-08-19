require 'flip'
require 'minitest/autorun'

class TestFlip < Minitest::Test

  def setup
    @mt_test = Flip.new(
      secret_key: "SB-Mid-server-uQmMImQMeo0Ky3Svl90QTUj2",
      valid_token: "SB-Mid-client-ArNfhrh7st9bQKmz",
      base_url_v2: "https://bigflip.id/big_sandbox_api/v2",
      base_url_v3: "https://bigflip.id/big_sandbox_api/v3",
      base_url_kyc: "https://api.flip.id/kyc-sandbox/api/v1",
      logger: Logger.new(STDOUT),
      file_logger: Logger.new(STDOUT)
    )
  end

  def test_create_widget_token
    result = @mt_test.create_widget_token(
      transaction_details: {
        order_id: "ruby-lib-test-#{Time.now.to_i}",
        gross_amount: 200000
      },
      "credit_card": {
        "secure": true
      }
    )
    assert_equal 201, result.status_code
  end

  def test_create_snap_token_string
    result = @mt_test.create_snap_token_string(
      transaction_details: {
        order_id: "ruby-lib-test-snap-#{Time.now.to_i}",
        gross_amount: 200000
      },
      "credit_card": {
        "secure": true
      }
    )
    assert result != nil
  end

  def test_snap_redirect_url_str
    result = @mt_test.create_snap_redirect_url_str(
      transaction_details: {
        order_id: "ruby-lib-test-snap#{Time.now.to_i}",
        gross_amount: 200000
      },
      "credit_card": {
        "secure": true
      }
    )
    assert_match "https://", result
  end

  def test_snap_invalid_serverkey
    @mt_test_invalid_key = Flip.new(
      secret_key: "invalid server key",
      secret_key: "invalid client key",
      base_url_v2: "https://bigflip.id/big_sandbox_api/v2",
      base_url_v3: "https://bigflip.id/big_sandbox_api/v3",
      base_url_kyc: "https://api.flip.id/kyc-sandbox/api/v1",
      logger: Logger.new(STDOUT),
      file_logger: Logger.new(STDOUT)
    )
    begin
    @mt_test_invalid_key.create_widget_token(
      transaction_details: {
        order_id: "ruby-lib-test-#{Time.now.to_i}",
        gross_amount: 200000
      },
      "credit_card": {
        "secure": true
      }
    )
    rescue FlipError => e
    assert_equal "401", e.status
    assert_match "please check client or server key", e.data
    end
  end

  end
