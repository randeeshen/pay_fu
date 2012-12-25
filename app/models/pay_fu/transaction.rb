#encoding: utf-8
require 'digest/md5'
require 'rexml/document'

module PayFu
  class Transaction < ActiveRecord::Base
    attr_accessible :trade_no, :payment_type, :trade_status, :notify_time, :total_fee, :raw_post, :type, :trial_order_no,
                    :subject, :gmt_create, :gmt_payment, :return_status, :gmt_refund, :receive_name, :receive_address, :receive_phone

    def self.close_trade_gateway(out_order_no)
      query_string = {
        :partner           => ActiveMerchant::Billing::Integrations::Alipay::ACCOUNT,
        :service           => 'close_trade',
        :"_input_charset"  => 'utf-8',
        :trade_role        => 'S',
        :out_order_no      => out_order_no
      }.sort.map { |key, value| "#{key}=#{CGI.unescape(value)}" }.join("&")

      sign = Digest::MD5.hexdigest(query_string + ActiveMerchant::Billing::Integrations::Alipay::KEY)
      query_string += "&sign=#{sign}&sign_type=MD5"

      colse_trade_url = 'https://mapi.alipay.com/gateway.do?' + query_string
      doc = REXML::Document.new(open(colse_trade_url) { |f| f.read })

      return doc.root.elements['is_success'].text, doc.root.elements['error'] ? doc.root.elements['error'].text : ""
    end

    def self.send_goods_confirm_gateway(out_trade_no, invoice_no)
      if transaction = PayFu::Transaction.find_by_trial_order_no(out_trade_no)
        trade_no = transaction.trade_no
      else
        return false
      end

      query_string = {
        :partner           => ActiveMerchant::Billing::Integrations::Alipay::ACCOUNT,
        :service           => 'send_goods_confirm_by_platform',
        :"_input_charset"  => 'utf-8',
        :trade_no          => trade_no,                          #支付宝交易号
        :logistics_name    => "顺丰快递",                        #物流公司名称
        :invoice_no        => invoice_no,                        #物流发货单号
        :transport_type    => "EXPRESS"                          #发货时物流类型
      }.sort.map { |key, value| "#{key}=#{CGI.unescape(value)}" }.join("&")

      sign = Digest::MD5.hexdigest(query_string + ActiveMerchant::Billing::Integrations::Alipay::KEY)
      query_string += "&sign=#{sign}&sign_type=MD5"

      send_goods_confirm_url = URI.escape('https://mapi.alipay.com/gateway.do?' + query_string)
      doc = REXML::Document.new(open(send_goods_confirm_url) { |f| f.read })
      if (response = doc.root.elements['response']) && response.elements['tradeBase'] && response.elements['tradeBase'].elements['trade_status']
        trade_status = response.elements['tradeBase'].elements['trade_status'].text
      end

      if doc.root.elements['is_success'].text == "T"
        transaction.update_attributes(trade_status: trade_status) if trade_status
        return true
      else
        return false
      end
    end
  end
end
