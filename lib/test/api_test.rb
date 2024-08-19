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

    @mt_test_invalid_key = Flip.new(
      secret_key: "invalid server key",
      secret_key: "invalid client key",
      base_url_v2: "https://bigflip.id/big_sandbox_api/v2",
      base_url_v3: "https://bigflip.id/big_sandbox_api/v3",
      base_url_kyc: "https://api.flip.id/kyc-sandbox/api/v1",
      logger: Logger.new(STDOUT),
      file_logger: Logger.new(STDOUT)
    )
  end

  def test_get_token_credit_card
    card = {
      card_number: 4811111111111114,
      card_cvv: 123,
      card_exp_month: 12,
      card_exp_year: 2025
    }
    result = @mt_test.test_token(card)
    assert_equal 200, result.status_code
    assert_equal "Credit card token is created as Token ID.", result.status_message
  end

  def test_charge_credit_card
    card = {
      card_number: 5211111111111117,
      card_cvv: 123,
      card_exp_month: 12,
      card_exp_year: 2025
    }
    get_token = @mt_test.test_token(card)
    result = @mt_test.charge(
      {
        "payment_type": "credit_card",
        "transaction_details": {
          "gross_amount": 10000,
          "order_id": "ruby-lib-test-creditcard-#{Time.now.to_i}"
        },
        "credit_card": {
          "token_id": "#{get_token.token_id}"
        }
      }
    )
    assert_equal "Success, Credit Card transaction is successful", result.status_message
    assert_equal 200, result.status_code
    assert_equal "Approved", result.channel_response_message
  end

  def test_charge_bca_va
    result = @mt_test.charge(
      {
        "payment_type": "bank_transfer",
        "transaction_details": {
          "gross_amount": 10000,
          "order_id": "ruby-lib-test-bcava#{Time.now.to_i}"
        },
        "bank_transfer": {
          "bank": "bca",
          "va_number": "1234567891"
        }
      }
    )
    assert_equal 201, result.status_code
    assert_equal "Success, Bank Transfer transaction is created", result.status_message
  end

  def test_charge_bni_va
    result = @mt_test.charge(
      {
        "payment_type": "bank_transfer",
        "transaction_details": {
          "gross_amount": 10000,
          "order_id": "ruby-lib-test-bniva-#{Time.now.to_i}"
        },
        "bank_transfer": {
          "bank": "bni",
          "va_number": "1234567891"
        }
      }
    )
    assert_equal 201, result.status_code
    assert_equal "Success, Bank Transfer transaction is created", result.status_message
  end

  def test_point_inquiry
    card = {
      card_number: 4617006959746656,
      card_cvv: 123,
      card_exp_month: 12,
      card_exp_year: 2026
    }
    result = @mt_test.test_token(card)
    card_point_response = @mt_test.point_inquiry(result.token_id)
    assert_equal 200, card_point_response.status_code
  end

  def test_charge_cimb_clicks
    result = @mt_test.charge(
      {
        "payment_type": "cimb_clicks",
        "transaction_details": {
          "order_id": "ruby-lib-test-cimbclicks-#{Time.now.to_i}",
          "gross_amount": 44000
        },
        "cimb_clicks": {
          "description": "Purchase of a Food Delivery"
        }
      }
    )
    assert_equal 201, result.status_code
    assert_equal "Success, CIMB Clicks transaction is successful", result.status_message
  end

  def test_charge_epay_bri
    result = @mt_test.charge(
      {
        "payment_type": "bri_epay",
        "transaction_details": {
          "order_id": "ruby-lib-test-epaybri-#{Time.now.to_i}",
          "gross_amount": 44000
        }
      }
    )
    assert_equal 201, result.status_code
    assert_equal "Success, BRI E-Pay transaction is successful", result.status_message
    assert_equal "pending", result.transaction_status
  end

  def test_charge_mandiri_bill
    result = @mt_test.charge(
      "payment_type": "echannel",
      "transaction_details": {
        "order_id": "ruby-lib-test-mandiribill-#{Time.now.to_i}",
        "gross_amount": 44000
      },
      "echannel": {
        "bill_info1": "Payment for:",
        "bill_info2": "Item descriptions"
      }
    )
    assert_equal 201, result.status_code
    assert_equal "OK, Mandiri Bill transaction is successful", result.status_message
    assert_equal "pending", result.transaction_status
  end

  def test_charge_indomaret
    result = @mt_test.charge(
      "payment_type": "cstore",
      "transaction_details": {
        "order_id": "ruby-lib-test-indomaret-#{Time.now.to_i}",
        "gross_amount": 44000
      },
      "cstore": {
        "store": "Indomaret",
        "message": "Message to display"
      }
    )
    assert_equal 201, result.status_code
    assert_equal "Success, cstore transaction is successful", result.status_message
    assert_equal "indomaret", result.store
  end

  def test_charge_alfamart
    result = @mt_test.charge(
      "payment_type": "cstore",
      "transaction_details": {
        "order_id": "ruby-lib-test-alfamart-#{Time.now.to_i}",
        "gross_amount": 44000
      },
      "cstore": {
        "store": "alfamart",
        "alfamart_free_text_1": "1st row of receipt",
        "alfamart_free_text_2": "2nd row",
        "alfamart_free_text_3": "3rd row"
      }
    )
    assert_equal 201, result.status_code
    assert_equal "Success, cstore transaction is successful", result.status_message
    assert_equal "alfamart", result.store
  end

  def test_charge_gopay
    result = @mt_test.charge(
      "payment_type": "gopay",
      "transaction_details": {
        "order_id": "ruby-lib-test-gopay-#{Time.now.to_i}",
        "gross_amount": 44000
      },
      "gopay": {
        "enable_callback": "true",
        "callback_url": "someapps://callback"
      }
    )
    assert_equal 201, result.status_code
    assert_equal "GoPay transaction is created", result.status_message
    assert_equal "pending", result.transaction_status
  end

  def test_charge_bcaklikpay
    result = @mt_test.charge(
      "payment_type": "bca_klikpay",
      "transaction_details": {
        "order_id": "ruby-lib-test-bcaklikpay-#{Time.now.to_i}",
        "gross_amount": 44000
      },
      "bca_klikpay": {
        "type": "1",
        "description": "pembelian produk"
      }
    )
    assert_equal 201, result.status_code
    assert_equal "OK, BCA KlikPay transaction is successful", result.status_message
    assert_equal "pending", result.transaction_status
  end

  def test_charge_akulaku
    result = @mt_test.charge(
      "payment_type": "akulaku",
      "transaction_details": {
        "order_id": "ruby-lib-test-#{Time.now.to_i}",
        "gross_amount": 44000
      }
    )
    assert_equal 201, result.status_code
    assert_equal "Success, Akulaku transaction is created", result.status_message
    assert_equal "pending", result.transaction_status
  end

  def test_charge_danamon_online
    result = @mt_test.charge(
      "payment_type": "danamon_online",
      "transaction_details": {
        "order_id": "ruby-lib-test-#{Time.now.to_i}",
        "gross_amount": 44000
      }
    )
    assert_equal "Success, Danamon Online transaction is successful", result.status_message
    assert_equal 201, result.status_code
    assert_equal "pending", result.transaction_status
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

  def test_fail_charge_invalid_key
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
    @mt_test_invalid_key.charge(
      {
        "payment_type": "bank_transfer",
        "transaction_details": {
          "gross_amount": 10000,
          "order_id": "ruby-lib-test-bcava-#{Time.now.to_i}"
        },
        "bank_transfer": {
          "bank": "bca",
          "va_number": "1234567891"
        }
      }
    )
    rescue FlipError => e
    assert_equal "401", e.status
    assert_match "Transaction cannot be authorized with the current client/server key.", e.data
    end
  end

  def test_fail_get_token
    @mt_test_invalid_key = Flip.new(
      secret_key: "invalid server key",
      secret_key: "invalid client key",
      base_url_v2: "https://bigflip.id/big_sandbox_api/v2",
      base_url_v3: "https://bigflip.id/big_sandbox_api/v3",
      base_url_kyc: "https://api.flip.id/kyc-sandbox/api/v1",
      logger: Logger.new(STDOUT),
      file_logger: Logger.new(STDOUT)
    )

    card = {
      card_number: 4617006959746656,
      card_cvv: 123,
      card_exp_month: 12,
      card_exp_year: 2026
    }
    begin
      @mt_test_invalid_key.test_token(card)
    rescue FlipError => e
      assert_equal "401", e.status
      assert_match "Transaction cannot be authorized with the current client/server key.", e.data
    end
  end

end
