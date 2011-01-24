class AddValueAndPaidToPayment < ActiveRecord::Migration
  def self.up
    add_column :payments, :value, :decimal, :precision => 8, 
                                            :scale => 2, 
                                            :default => 0
    add_column :payments, :paid, :decimal, :precision => 8,
                                           :scale => 2,
                                           :default => 0
  end

  def self.down
    remove_column :payments, :value
    remove_column :payments, :paid
  end
end
