require 'flip'
require 'minitest/autorun'

class TestFlip < Minitest::Test
  i_suck_and_my_tests_are_order_dependent!

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

  def test_link_payment_account
    p 1
    param = {
      "payment_type": "gopay",
      "gopay_partner": {
        "phone_number": "81987654321",
        "country_code": "62",
        "redirect_url": "https://www.gojek.com"
      }
    }
    result = @mt_test.link_payment_account(param)
    assert_equal 201, result.status_code
    assert_equal "PENDING", result.account_status
    $test_gopay_id = result.account_id
  end

  def test_get_payment_account
    p 2
    param = {
      "payment_type": "gopay",
      "gopay_partner": {
        "phone_number": "81987654321",
        "country_code": "62",
        "redirect_url": "https://www.gojek.com"
      }
    }
    charge = @mt_test.link_payment_account(param)
    result = @mt_test.get_payment_account(charge.account_id)
    assert_equal 201, result.status_code
    assert_equal "PENDING", result.account_status
  end

  def test_unlink_payment_account
    #expected the API call will fail because of not click activation from link_payment_account
    p 3
    begin
      @mt_test.unlink_payment_account($test_gopay_id)
    rescue FlipError => e
      assert_equal "412", e.status
      assert_match "Account status cannot be updated.", e.data
    end
  end

  def test_get_payment_acc_dummy
    p 4
    begin
    @mt_test.get_payment_account("dummy")
    rescue FlipError => e
    assert_equal "404", e.status
    assert_match "Account doesn't exist.", e.data
    end
  end

  def test_unlink_dummy_account
    p 5
    begin
    @mt_test.unlink_payment_account("dummy")
    rescue FlipError => e
    assert_equal "404", e.status
    assert_match "Account doesn't exist.", e.data
    end
  end

end