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

  def test_charge_permata_va
    result = @mt_test.charge(
      {
        "payment_type": "bank_transfer",
        "transaction_details": {
          "gross_amount": 10000,
          "order_id": "ruby-lib-test-#{Time.now.to_i}"
        },
        "bank_transfer": {
          "bank": "permata",
          "va_number": "1234567891"
        }
      }
    )
    assert_equal 201, result.status_code
    assert_equal "pending", result.transaction_status
    assert_equal "Success, PERMATA VA transaction is successful", result.status_message
  end

  def test_cancel_permata_va
    charge = @mt_test.charge(
      {
        "payment_type": "bank_transfer",
        "transaction_details": {
          "gross_amount": 10000,
          "order_id": "ruby-lib-test-#{Time.now.to_i}"
        },
        "bank_transfer": {
          "bank": "permata",
          "va_number": "1234567891"
        }
      }
    )
    cancel = @mt_test.cancel(charge.transaction_id)
    assert_equal 200, cancel.status_code
    assert_equal "cancel", cancel.transaction_status
  end

  def test_expire_permata_va
    charge = @mt_test.charge(
      {
        "payment_type": "bank_transfer",
        "transaction_details": {
          "gross_amount": 10000,
          "order_id": "ruby-lib-test-#{Time.now.to_i}"
        },
        "bank_transfer": {
          "bank": "permata",
          "va_number": "1234567891"
        }
      }
    )
    expire = @mt_test.expire(charge.transaction_id)
    assert_equal "Success, transaction has expired", expire.status_message
    assert_equal 407, expire.status_code
    assert_equal "expire", expire.transaction_status
  end

  def test_get_status_transaction
    charge = @mt_test.charge(
      {
        "payment_type": "bank_transfer",
        "transaction_details": {
          "gross_amount": 10000,
          "order_id": "ruby-lib-test-#{Time.now.to_i}"
        },
        "bank_transfer": {
          "bank": "permata",
          "va_number": "1234567891"
        }
      }
    )
    result = @mt_test.status(charge.transaction_id)
    assert_equal 201, result.status_code
    assert_equal "Success, transaction is found", result.status_message
  end

  def test_approve_transaction
    card = {
      card_number: 5510111111111115,
      card_cvv: 123,
      card_exp_month: 12,
      card_exp_year: 2025
    }
    get_token = @mt_test.test_token(card)
    charge = @mt_test.charge(
      {
        "payment_type": "credit_card",
        "transaction_details": {
          "gross_amount": 10000,
          "order_id": "ruby-lib-test-#{Time.now.to_i}"
        },
        "credit_card": {
          "token_id": "#{get_token.token_id}",
          "authentication": "false"
        }
      }
    )
    result = @mt_test.approve(charge.transaction_id)
    assert_equal "Success, transaction is approved", result.status_message
    assert_equal 200, result.status_code
    assert_equal "accept", result.fraud_status
  end

  def test_deny_transaction
    card = {
      card_number: 5510111111111115,
      card_cvv: 123,
      card_exp_month: 12,
      card_exp_year: 2025
    }
    get_token = @mt_test.test_token(card)
    charge = @mt_test.charge(
      {
        "payment_type": "credit_card",
        "transaction_details": {
          "gross_amount": 10000,
          "order_id": "ruby-lib-test-#{Time.now.to_i}"
        },
        "credit_card": {
          "token_id": "#{get_token.token_id}",
          "authentication": "false"
        }
      }
    )
    result = @mt_test.deny(charge.transaction_id)
    assert_equal 200, result.status_code
    assert_equal "Success, transaction is denied", result.status_message
    assert_equal "deny", result.fraud_status
  end

  def test_fail_refund_transaction
    begin
    param = {
      "refund_key": "reference1",
      "amount": 5000,
      "reason": "for some reason"
    }
    @mt_test.refund("dummy-order-id", param)
    rescue FlipError => e
      assert_equal "404", e.status
      end
  end

  end
