class DropStripeWrappersTable < ActiveRecord::Migration
  def up
    drop_table :stripe_wrappers
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
