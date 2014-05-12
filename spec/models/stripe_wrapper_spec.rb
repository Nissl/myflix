require 'spec_helper'

describe StripeWrapper::Charge do
  before { StripeWrapper.set_api_key } 

  let(:token) do
    Stripe::Token.create(
      :card => {
        :number => card_number,
        :exp_month => 3,
        :exp_year => 2020,
        :cvc => 314
        }
      ).id
  end

  context "with valid card" do
    let(:card_number) { '4242424242424242' }
    
    it "charges the card successfully" do
      VCR.use_cassette('valid_card') do
        response = StripeWrapper::Charge.create(amount: 300, card: token)
        expect(response).to be_successful
      end
    end
  end

  context "with invalid card" do
    let(:card_number) { '4000000000000002' }

    it "does not charge the card" do
      VCR.use_cassette('invalid_card') do
        response = StripeWrapper::Charge.create(amount: 300, card: token)
        expect(response).to_not be_successful
      end
    end

    it "contains an error message" do
      VCR.use_cassette('invalid_card') do
        response = StripeWrapper::Charge.create(amount: 300, card: token)
        expect(response.error_message).to eq('Your card was declined.')
      end
    end
  end
end