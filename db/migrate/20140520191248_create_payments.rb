class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.string :user_id
      t.string :amount
      t.string :reference_id
      t.timestamps
    end
  end
end
