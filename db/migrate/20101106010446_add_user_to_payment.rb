class AddUserToPayment < ActiveRecord::Migration
  def self.up
    add_column :payments, :user_id, :integer
  end

  def self.down
    remove_column :payments, :user_id
  end
end
