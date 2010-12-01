class CreateCredits < ActiveRecord::Migration
  def self.up
    create_table :credits do |t|
      t.integer :user_id
      t.integer :other_user_id
      t.decimal :value

      t.timestamps
    end
  end

  def self.down
    drop_table :credits
  end
end
