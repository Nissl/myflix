class RenameUserStripeIdColumn < ActiveRecord::Migration
  def change
    rename_column :users, :customer_id, :customer_token
  end
end
