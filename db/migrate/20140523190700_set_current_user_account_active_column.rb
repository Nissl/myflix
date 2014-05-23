class SetCurrentUserAccountActiveColumn < ActiveRecord::Migration
  def change
    User.all.each do |user|
      user.update_column(:account_active, true) if user.account_active == nil
    end
  end
end
