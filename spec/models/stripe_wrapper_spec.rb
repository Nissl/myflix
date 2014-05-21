require 'spec_helper'

describe StripeWrapper, vcr: true do
  let(:token) do
    Stripe::Token.create(
      :card => {
        :number => '4242424242424242',
        :exp_month => 3,
        :exp_year => 2020,
        :cvc => 314
      }
    ).id
  end

  let(:declined_card_token) do
    Stripe::Token.create(
      :card => {
        :number => '4000000000000002',
        :exp_month => 3,
        :exp_year => 2020,
        :cvc => 314
      }
    ).id
  end

  describe StripeWrapper::Charge do
    describe ".create" do
      context "with valid card" do
        it "charges the card successfully" do
          charge = StripeWrapper::Charge.create(
            amount: 300, 
            card: token
          )
          expect(charge.successful?).to be_true
        end
      end

      context "with invalid card" do
        it "does not charge the card" do
          charge = StripeWrapper::Charge.create(
            amount: 300, 
            card: declined_card_token
          )
          expect(charge.successful?).to_not be_true
        end

        it "contains an error message" do
          charge = StripeWrapper::Charge.create(
            amount: 300, 
            card: declined_card_token
          )
          expect(charge.error_message).to eq('Your card was declined.')
        end
      end
    end
  end

  describe StripeWrapper::Customer do
    describe ".create" do
      context "with valid card" do
        it "creates a customer" do
          alice = Fabricate.build(:user)
          customer = StripeWrapper::Customer.create(
            amount: 300, 
            card: token, 
            user: alice
          )
          expect(customer.created?).to be_true
        end

        it "returns the customer token" do
          alice = Fabricate.build(:user)
          customer = StripeWrapper::Customer.create(
            amount: 300, 
            card: token, 
            user: alice
          )
          expect(customer.customer_token).to be_present
        end
      end

      context "with invalid card" do
        it "does not create a customer" do
          alice = Fabricate.build(:user)
          customer = StripeWrapper::Customer.create(
            amount: 300, 
            card: declined_card_token, 
            user: alice
          )
          expect(customer.created?).to_not be_true
        end

        it "contains an error message" do
          alice = Fabricate.build(:user)
          customer = StripeWrapper::Customer.create(
            amount: 300, 
            card: declined_card_token, 
            user: alice
          )
          expect(customer.error_message).to eq('Your card was declined.')
        end
      end
    end
  end
end