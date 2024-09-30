# Flip API methods

require 'erb'

class Flip
  module Api

    def bank_info(code)
      result = get(config.base_url_v2 + "/general/banks", {code: code})
      p result
    end

    def bank_account_inquiry(data)
      # account_number = data[:account_number]
      # bank_code = data[:bank_code]
      # inquiry_key = data[:inquiry_key]
      result = post(config.base_url_v2 + "/disbursement/bank-account-inquiry", data)
      p result
    end

    def balance
      result = get(config.base_url_v2 + "/general/balance")
      result.data[:balance]
    end

    def create_link(data)
      data2 = data.dup
      data2[:amount] = data[:amount].to_s if data[:amount].is_a?(Integer)
      data2[:step] = data[:step].to_s if data[:step].is_a?(Integer)
      request_with_logging(:post, config.base_url_v2 + "/pwf/bill", data2)

      # DEBUG
      # message = "FLIP gem create_link env yg dipakai config.envi #{config.envi} config.base_url_v2 #{config.base_url_v2} config.secret_key #{config.secret_key} config.valid_token #{config.valid_token}"
      # NotifyDevJob.perform_later message
    end

    def disbursement(data)
      data = data.dup
      data[:account_number] = data[:account_number].to_s if data[:account_number].is_a?(Integer)
      data[:amount] = data[:amount].to_s if data[:amount].is_a?(Integer)
      data[:remark] = data[:remark][0..17] if data[:remark].is_a?(String)
      request_with_logging(:post, config.base_url_v3 + "/disbursement", data)
    end

    def get_disbursement(id: nil, idempotency: nil)
      if id
        result = get(config.base_url_v3 + "/get-disbursement", {id: id})
        result.data
      elsif idempotency
        result = get(config.base_url_v3 + "/get-disbursement", {'idempotency-key' => idempotency})
        result.data
      else
        # warn "Warning: Neither id nor idempotency key provided."
      end
    end

    def get_disbursements(pagination: 10, page: 1)
      result = get(config.base_url_v3 + "/disbursement", {sort: '-id', pagination: pagination, page: page})
      result.data
    end
  end
end

# https://bigflip.id/api/v3/disbursement?pagination=pagination&page=page&sort=sort&atribut=value");
# https://bigflip.id/api/v3/get-disbursement?id=id
# DEBUG
# message = "FLIP gem balance env yg dipakai `config.envi #{config.envi}` `config.base_url_v2 #{config.base_url_v2}` `config.secret_key #{config.secret_key}` `config.valid_token #{config.valid_token}`"
# NotifyDevJob.perform_later message