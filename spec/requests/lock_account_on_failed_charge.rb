require 'spec_helper'

describe 'Lock account on failed charge' do
  def stub_event(fixture_id, status=200)
   WebMock.stub_request(:get, "https://api.stripe.com/v1/events/#{fixture_id}").
      to_return(status: status, body: File.read("spec/support/fixtures/#{fixture_id}.json"))
  end

  before { stub_event 'evt_00000000000000' }
  after { ActionMailer::Base.deliveries.clear }

  it "deactivates the user account" do
    alice = Fabricate(:user, 
                      customer_token: "cus_123", 
                      account_active: true)
    post '/stripe_events', id: 'evt_00000000000000'
    expect(alice.reload.account_active).to be_false
  end

  it "sends out an email" do
    alice = Fabricate(:user, 
                      customer_token: "cus_123", 
                      account_active: true)
    post '/stripe_events', id: 'evt_00000000000000'
    expect(ActionMailer::Base.deliveries).not_to be_empty
  end

  it "sends the email to the user" do
    alice = Fabricate(:user, 
                      customer_token: "cus_123", 
                      account_active: true)
    post '/stripe_events', id: 'evt_00000000000000'
    message = ActionMailer::Base.deliveries.last
    expect(message.to).to eq([alice.email])
  end

  it "sends the email containing a warning that their account has been locked" do
    alice = Fabricate(:user, 
                      customer_token: "cus_123", 
                      account_active: true)
    post '/stripe_events', id: 'evt_00000000000000'
    message = ActionMailer::Base.deliveries.last
    expect(message.body).to include("Hi, #{alice.full_name}, your account has been locked due to a failed credit card charge.")
  end
end