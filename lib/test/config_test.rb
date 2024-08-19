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

  def test_base_url_v2
    assert_equal "https://api.sandbox.flip.com", Flip.config.base_url_v2
  end

  def test_base_url_v3
    assert_equal "https://api.sandbox.flip.com", Flip.config.base_url_v3
  end

  def test_base_url_kyc
    assert_equal "https://api.sandbox.flip.com", Flip.config.base_url_kyc
  end

  def test_secret_key_secret_key
    Flip.config.secret_key = "kk-1"
    Flip.config.secret_key = "sk-1"

    assert_equal "kk-1", Flip.config.secret_key
    assert_equal "sk-1", Flip.config.secret_key
  end
end