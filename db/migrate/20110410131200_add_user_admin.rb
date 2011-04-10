class AddUserAdmin < ActiveRecord::Migration
  def self.up
    User.create(:name => 'Admin',
                :username => 'admin',
                :password => 'admin', 
                :password_confirmation => 'admin',
                :admin => true)
  end

  def self.down
    User.find_by_username('admin').destroy
  end
end
