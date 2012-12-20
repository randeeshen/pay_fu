module PayFu
  class PaypalTransactionsController < ApplicationController
    include ActiveMerchant::Billing::Integrations

    def notify
      notify = Paypal::Notification.new(request.raw_post)
      if notify.acknowledge
        if transaction = PayFu::PaypalTransaction.find_by_trade_no(notify.transaction_id)
          transaction.update_attributes(transaction_attributes(notify))
        else
          PayFu::PaypalTransaction.create(transaction_attributes(notify))
        end
      end
      render :nothing => true
    end

    def transaction_attributes(notify)
      @transaction_attributes ||= {
        :trade_no => notify.transaction_id,
        :payment_type => notify.type,
        :trade_status => notify.status,
        :notify_time => notify.received_at,
        :total_fee => notify.gross_cents,
        :raw_post => notify.raw
      }
    end
  end
end
