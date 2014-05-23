require 'spec_helper'

feature "Admin views payments" do
  background do
    alice = Fabricate(:user)
    bob = Fabricate(:user)
    Fabricate(:payment, user_id: alice.id)
    Fabricate(:payment, user_id: bob.id)
  end

  scenario "admin views recent payments" do
    charlie = Fabricate(:admin)

    sign_in_user(charlie)
    visit admin_payments_path
    expect(page).to have_content(User.first.full_name)
    expect(page).to have_content(User.find(2).full_name)
    expect(page).to have_content("$9.99")
    expect(page).to have_content(User.first.email)
  end

  scenario "user cannot see payments" do
    diana = Fabricate(:user)
    sign_in_user(diana)
    visit admin_payments_path
    expect(page).not_to have_content(User.first.full_name)
    expect(page).to have_content("You do not have permission to do that.")
  end
end