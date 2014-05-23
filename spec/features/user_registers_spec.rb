require 'spec_helper'

feature 'User registers', { js: true, vcr: true } do
  background { visit register_path }

  scenario 'with valid personal info and valid card' do
    alice = Fabricate.build(:user)
    
    fill_in_user_info(alice)
    fill_in_valid_credit_card_info
    click_register
    confirm_successful_registration(alice)
    sign_in_user(alice)
    confirm_user_registered(alice)
    clear_emails
  end

  scenario 'with valid personal info and invalid card' do
    alice = Fabricate.build(:user)
    fill_in_user_info(alice)
    click_register
    confirm_rejection_for_invalid_card
    sign_in_user(alice)
    confirm_user_not_registered
  end

  scenario 'with valid personal info and card declined' do
    alice = Fabricate.build(:user)
    
    fill_in_user_info(alice)
    fill_in_declined_credit_card_info
    click_register
    confirm_rejection_for_declined_card
    sign_in_user(alice)
    confirm_user_not_registered
  end

  scenario 'with invalid personal info and valid card' do
    alice = Fabricate.build(:bad_user)
    
    fill_in_user_info(alice)
    fill_in_valid_credit_card_info
    click_register
    confirm_rejection_for_invalid_info
    sign_in_user(alice)
    confirm_user_not_registered
  end

  scenario 'with invalid personal info and invalid card' do
    alice = Fabricate.build(:bad_user)
    
    fill_in_user_info(alice)
    fill_in_invalid_credit_card_info
    click_register
    confirm_rejection_for_invalid_card
    sign_in_user(alice)
    confirm_user_not_registered
  end

  scenario 'with invalid personal info and card declined' do
    alice = Fabricate.build(:bad_user)
    
    fill_in_user_info(alice)
    fill_in_declined_credit_card_info
    click_register
    confirm_rejection_for_invalid_info
    sign_in_user(alice)
    confirm_user_not_registered
  end
end

def confirm_rejection_for_invalid_card 
  expect(page).to have_content("This card number looks invalid")
end

def confirm_rejection_for_declined_card 
  expect(page).to have_content("Your card was declined.")
end

def confirm_rejection_for_invalid_info
  expect(page).to have_content("Please correct the following errors:")
  expect(page).to have_content("can't be blank")
end