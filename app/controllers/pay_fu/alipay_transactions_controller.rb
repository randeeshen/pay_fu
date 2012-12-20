module PayFu
  class AlipayTransactionsController < ApplicationController
    include ActiveMerchant::Billing::Integrations

    def notify
      notify = Alipay::Notification.new(request.raw_post)   # new_post ?
      if notify.acknowledge
        if transaction = PayFu::AlipayTransaction.find_by_trade_no(notify.trade_no)
          transaction.update_attributes(transaction_attributes(notify))
        else
          PayFu::AlipayTransaction.create(transaction_attributes(notify))
        end
      end
      render :nothing => true
    end

    def transaction_attributes(notify)
      @transaction_attributes ||= {
        :trade_no => notify.trade_no,
        :payment_type => notify.payment_type,
        :trade_status => notify.trade_status,
        :notify_time => notify.notify_time,
        :total_fee => notify.total_fee,
        :raw_post => notify.raw
      }
    end
  end
end
