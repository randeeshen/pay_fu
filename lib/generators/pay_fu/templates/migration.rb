class CreatePayFuTransactions < ActiveRecord::Migration
  def change
    create_table :pay_fu_transactions do |t|
      t.string   :type
      t.string   :trade_no
      t.string   :payment_type
      t.string   :trade_status
      t.datetime :notify_time
      t.integer  :total_fee
      t.text     :raw_post

      t.timestamps
    end
  end
end
