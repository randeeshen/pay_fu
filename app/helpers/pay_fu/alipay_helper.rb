#encoding: utf-8
require 'digest/md5'

module PayFu
  module AlipayHelper
    def redirect_to_alipay_gateway(options={})
      query_string = {
        :partner           => ActiveMerchant::Billing::Integrations::Alipay::ACCOUNT,
        :seller_email      => ActiveMerchant::Billing::Integrations::Alipay::EMAIL,
        :service           => ActiveMerchant::Billing::Integrations::Alipay::Helper::CREATE_PARTNER_TRADE_BY_BUYER,
        :"_input_charset"  => 'utf-8',
        :payment_type      => "1",
        :quantity          => "1",
        :out_trade_no      => options[:out_trade_no],
        :notify_url        => options[:notify_url],
        :return_url        => options[:return_url],
        :body              => options[:body],
        :subject           => options[:subject],
        :logistics_payment => "BUYER_PAY_AFTER_RECEIVE",  # 买家货到付款
        :logistics_type    => "EXPRESS",
        :logistics_fee     => options[:logistics_fee],    # "0.1"
        :price             => options[:price],            #应付总额(扣除信用额)"0.1"
        :receive_name      => options[:receive_name],
        :receive_address   => options[:receive_address],
        :receive_mobile    => options[:receive_mobile]
      }.sort.map { |key, value| "#{key}=#{CGI.unescape(value)}" }.join("&")

      sign = Digest::MD5.hexdigest(query_string + ActiveMerchant::Billing::Integrations::Alipay::KEY)
      query_string += "&sign=#{sign}&sign_type=MD5"

      redirect_to 'https://mapi.alipay.com/gateway.do?' + query_string
    end

    def redirect_to_alipay_fast_login_gateway(options={})
      query_string = {
        :service           => "alipay.auth.authorize",
        :partner           => ActiveMerchant::Billing::Integrations::Alipay::ACCOUNT,
        :"_input_charset"  => 'utf-8',
        :target_service    => "user.auth.quick.login",
        :return_url        => options[:return_url]
      }.sort.map { |key, value| "#{key}=#{CGI.unescape(value)}" }.join("&")

      sign = Digest::MD5.hexdigest(query_string + ActiveMerchant::Billing::Integrations::Alipay::KEY)
      query_string += "&sign=#{sign}&sign_type=MD5"

      redirect_to 'https://mapi.alipay.com/gateway.do?' + query_string
    end
  end
end
