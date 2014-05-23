class ChangePaymentColumnsToInteger < ActiveRecord::Migration
  def up
  connection.execute(%q{
    alter table payments
    alter column user_id
    type integer using cast(user_id as integer)
  })
  connection.execute(%q{
    alter table payments
    alter column amount
    type integer using cast(amount as integer)
  })
  end

  def down
    change_table :tweets do |t|
      t.change :user_id, :string
      t.change :amount, :string
    end
  end
end
