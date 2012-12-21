#encoding: utf-8
require 'digest/md5'

module PayFu
  class Transaction < ActiveRecord::Base
    attr_accessible :trade_no, :payment_type, :trade_status, :notify_time, :total_fee, :raw_post, :type, :trial_order_no,
                    :subject, :gmt_create, :gmt_payment, :return_status, :gmt_refund, :receive_name, :receive_address, :receive_phone

    def self.close_trade_uri_gateway(out_trade_no)
      query_string = {
        :service           => "close_trade",
        :partner           => ActiveMerchant::Billing::Integrations::Alipay::ACCOUNT,
        :"_input_charset"  => 'utf-8',
        :out_trade_no      => out_trade_no
      }.sort.map { |key, value| "#{key}=#{CGI.unescape(value)}" }.join("&")

      sign = Digest::MD5.hexdigest(query_string + ActiveMerchant::Billing::Integrations::Alipay::KEY)
      query_string += "&sign=#{sign}&sign_type=MD5"

      return 'https://mapi.alipay.com/gateway.do?' + query_string
    end
  end
end
