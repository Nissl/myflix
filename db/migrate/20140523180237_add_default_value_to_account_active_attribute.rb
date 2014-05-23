class AddDefaultValueToAccountActiveAttribute < ActiveRecord::Migration
  def up
      change_column :users, :account_active, :boolean, :default => true
  end

  def down
      change_column :users, :account_active, :boolean, :default => nil
  end
end
