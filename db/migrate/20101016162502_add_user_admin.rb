class AddUserAdmin < ActiveRecord::Migration
  def self.up
    User.create(:name => 'admin', 
                :password => 'admin', 
                :password_confirmation => 'admin')
  end

  def self.down
    User.find_by_name('admin').delete
  end
end
