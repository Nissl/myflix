class AddAccountActiveColumnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :account_active, :boolean
  end
end
