require 'spec_helper'

describe "Create payment on successful charge", vcr: true do
  let!(:event_data) do 
    { "id" => "evt_10448U4XNy2YPdws6VDZb5tr",
      "created" => 1400542267,
      "livemode" => false,
      "type" => "charge.succeeded",
      "data" => {
        "object" => {
          "id" => "ch_10448U4XNy2YPdwstrbjIl8B",
          "object" => "charge",
          "created" => 1400542267,
          "livemode" => false,
          "paid" => true,
          "amount" => 999,
          "currency" => "usd",
          "refunded" => false,
          "card" => {
            "id" => "card_10448U4XNy2YPdwsTNun5RM5",
            "object" => "card",
            "last4" => "4242",
            "type" => "Visa",
            "exp_month" => 10,
            "exp_year" => 2014,
            "fingerprint" => "Y6WJ0n1gVFVTeAgP",
            "customer" => "cus_448UYAaUzkqYux",
            "country" => "US",
            "name" => nil,
            "address_line1" => nil,
            "address_line2" => nil,
            "address_city" => nil,
            "address_state" => nil,
            "address_zip" => nil,
            "address_country" => nil,
            "cvc_check" => "pass",
            "address_line1_check" => nil,
            "address_zip_check" => nil
          },
          "captured" => true,
          "refunds" => [],
          "balance_transaction" => "txn_10448U4XNy2YPdwslp9RSSi6",
          "failure_message" => nil,
          "failure_code" => nil,
          "amount_refunded" => 0,
          "customer" => "cus_448UYAaUzkqYux",
          "invoice" => "in_10448U4XNy2YPdwsOtrXSVig",
          "description" => nil,
          "dispute" => nil,
          "metadata" => {},
          "statement_description" => nil
        }
      },
      "object" => "event",
      "pending_webhooks" => 1,
      "request" => "iar_448UH5ORBA0TLH"
    }
  end

  it "creates a payment with the webhook from stripe for charge.succeeded"  do
    alice = Fabricate(:user, customer_token: event_data["data"]["object"]["card"]["customer"])
    post "/stripe_events", event_data
    expect(Payment.count).to eq(1)
  end

  it "creates a payment associated with the user" do
    alice = Fabricate(:user, customer_token: event_data["data"]["object"]["card"]["customer"])
    post "/stripe_events", event_data
    expect(Payment.first.user).to eq(alice)
  end

  it "creates a payment with an amount" do
    alice = Fabricate(:user, customer_token: event_data["data"]["object"]["card"]["customer"])
    post "/stripe_events", event_data
    expect(Payment.first.amount).to eq(event_data["data"]["object"]["amount"])
  end

  it "creates a payment with a reference ID" do 
    alice = Fabricate(:user, customer_token: event_data["data"]["object"]["card"]["customer"])
    post "/stripe_events", event_data
    expect(Payment.first.reference_id).to eq(event_data["data"]["object"]["id"])    
  end
end