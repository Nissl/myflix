require 'spec_helper'

describe 'Lock account on failed charge' do
  after { ActionMailer::Base.deliveries.clear }

  it "deactivates the user account" do
    alice = Fabricate(:user, 
                      customer_token: "cus_44UO0lmwIiGjvW", 
                      account_active: true)
    require 'pry'; binding.pry
    post '/stripe_events', id: "evt_1045FM4XNy2YPdwsCtDbU9HB"
    expect(alice.reload.account_active).to be_false
  end

  it "sends out an email" do
    alice = Fabricate(:user, 
                      customer_token: "cus_44UO0lmwIiGjvW", 
                      account_active: true)
    post '/stripe_events', id: "evt_1045FM4XNy2YPdwsCtDbU9HB"
    expect(ActionMailer::Base.deliveries).not_to be_empty
  end

  it "sends the email to the user" do
    alice = Fabricate(:user, 
                      customer_token: "cus_44UO0lmwIiGjvW", 
                      account_active: true)
    post '/stripe_events', id: "evt_1045FM4XNy2YPdwsCtDbU9HB"
    message = ActionMailer::Base.deliveries.last
    expect(message.to).to eq([alice.email])
  end

  it "sends the email containing a warning that their account has been locked" do
    alice = Fabricate(:user, 
                      customer_token: "cus_44UO0lmwIiGjvW", 
                      account_active: true)
    post '/stripe_events', id: "evt_1045FM4XNy2YPdwsCtDbU9HB"
    message = ActionMailer::Base.deliveries.last
    expect(message.body).to include("Hi, #{alice.full_name}, your account has been locked due to a failed credit card charge.")
  end
end