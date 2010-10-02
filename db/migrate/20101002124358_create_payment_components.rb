class CreatePaymentComponents < ActiveRecord::Migration
  def self.up
    create_table :payment_components do |t|
      t.integer :payment_id
      t.decimal :value
      t.decimal :paid
      t.decimal :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :payment_components
  end
end
