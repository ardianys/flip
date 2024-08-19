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

  def test_create_subscription
    p 1
    param = {
      "name": "MONTHLY_2021",
      "amount": "17000",
      "currency": "IDR",
      "payment_type": "credit_card",
      "token": "dummy",
      "schedule": {
        "interval": 1,
        "interval_unit": "month",
        "max_interval": 12,
        "start_time": "2022-10-10 07:25:01 +0700"
      },
      "metadata": {
        "description": "Recurring payment for A"
      },
      "customer_details": {
        "first_name": "John",
        "last_name": "Doe",
        "email": "johndoe@email.com",
        "phone": "+62812345678"
      }
    }
    result = @mt_test.create_subscription(param)
    assert_equal 200, result.status
    $testsubsid = result.id
  end

  def test_get_subscription
    p 2
    result = @mt_test.get_subscription($testsubsid)
    assert_equal 200, result.status
  end

  def test_disable_subscription
    p 3
    result = @mt_test.disable_subscription($testsubsid)
    assert_equal "Subscription is updated.", result.status_message
  end

  def test_enable_subscription
    p 4
    result = @mt_test.enable_subscription($testsubsid)
    assert_equal "Subscription is updated.", result.status_message
  end

  def test_update_subscription
    p 5
    param = {
      "name": "MONTHLY_2021",
      "amount": "21000",
      "currency": "IDR",
      "token": "dummy",
      "schedule": {
        "interval": 1
      }
    }
    result = @mt_test.update_subscription($testsubsid, param)
    assert_equal "Subscription is updated.", result.status_message
  end

  def test_get_subscription_none_acc
    begin
      @mt_test.get_subscription("dummy")
    rescue FlipError => e
      assert_equal "404", e.status
      assert_match "Subscription doesn't exist.", e.data
    end
  end

  def test_disable_subscription_none
    begin
      @mt_test.disable_subscription("dummy")
    rescue FlipError => e
      assert_equal "404", e.status
      assert_match "Subscription doesn't exist.", e.data
    end
  end

  def test_enable_subscription_none
    begin
      @mt_test.enable_subscription("dummy")
    rescue FlipError => e
      assert_equal "404", e.status
      assert_match "Subscription doesn't exist.", e.data
    end
  end

  def test_update_subscription_none
    begin
      param = {}
      @mt_test.update_subscription("dummy", param)
    rescue FlipError => e
      assert_equal "404", e.status
      assert_match "Subscription doesn't exist.", e.data
    end
  end

end