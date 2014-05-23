require 'spec_helper'

describe "Create payment on successful charge", vcr: true do
  it "creates a payment with the webhook from stripe for charge.succeeded"  do
    alice = Fabricate(:user, customer_token: "cus_448UYAaUzkqYux")
    post "/stripe_events", id: "evt_10448U4XNy2YPdws6VDZb5tr"
    expect(Payment.count).to eq(1)
  end

  it "creates a payment associated with the user" do
    alice = Fabricate(:user, customer_token: "cus_448UYAaUzkqYux")
    post "/stripe_events", id: "evt_10448U4XNy2YPdws6VDZb5tr"
    expect(Payment.first.user).to eq(alice)
  end

  it "creates a payment with an amount" do
    alice = Fabricate(:user, customer_token: "cus_448UYAaUzkqYux")
    post "/stripe_events", id: "evt_10448U4XNy2YPdws6VDZb5tr"
    expect(Payment.first.amount).to eq(999)
  end

  it "creates a payment with a reference ID" do 
    alice = Fabricate(:user, customer_token: "cus_448UYAaUzkqYux")
    post "/stripe_events", id: "evt_10448U4XNy2YPdws6VDZb5tr"
    expect(Payment.first.reference_id).to eq("ch_10448U4XNy2YPdwstrbjIl8B")    
  end

  it "activates the user's account if it is not already activated" do
    alice = Fabricate(:user, customer_token: "cus_448UYAaUzkqYux")
    post "/stripe_events", id: "evt_10448U4XNy2YPdws6VDZb5tr"
    expect(alice.reload.account_active).to be_true
  end
end