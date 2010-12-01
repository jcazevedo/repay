class CreatePaymentComponents < ActiveRecord::Migration
  def self.up
    create_table :payment_components do |t|
      t.integer :payment_id
      t.decimal :value, :precision => 8, :scale => 2, :default => 0
      t.decimal :paid, :precision => 8, :scale => 2, :default => 0
      t.decimal :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :payment_components
  end
end
