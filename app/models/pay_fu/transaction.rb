module PayFu
  class Transaction < ActiveRecord::Base
    attr_accessible :trade_no, :payment_type, :trade_status, :notify_time, :total_fee, :raw_post, :type, :trial_order_no,
                    :subject, :gmt_create, :gmt_payment, :return_status, :gmt_refund, :receive_name, :receive_address, :receive_phone
  end
end
