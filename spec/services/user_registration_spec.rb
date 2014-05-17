require 'spec_helper'      

describe UserRegistration do
  describe "#register_user" do
    after { ActionMailer::Base.deliveries.clear }
    
    context "card is valid" do
      before do
        charge = double(:charge, successful?: true)
        StripeWrapper::Charge.stub(:create).and_return(charge)
      end

      it "creates a new user" do
        alice = Fabricate.build(:user)
        UserRegistration.new(alice).register_user({stripeToken: "123"})
        expect(alice.save).to be_true
      end

      it "makes the user follow the inviter, if invited" do
        alice = Fabricate(:user)
        bob = Fabricate.build(:user)
        invitation = Fabricate(:invitation,
                               recipient_email: bob.email,
                               recipient_name: bob.full_name,
                               inviter_id: alice.id)
        UserRegistration.new(bob).register_user({invitation_token: invitation.token, 
                                                   stripeToken: "123"})
        expect(bob.follows?(alice)).to be_true
      end 

      it "makes the inviter follow the user, if invited" do 
        alice = Fabricate(:user)
        bob = Fabricate.build(:user)
        invitation = Fabricate(:invitation,
                               recipient_email: bob.email,
                               recipient_name: bob.full_name,
                               inviter_id: alice.id)
        UserRegistration.new(bob).register_user({invitation_token: invitation.token, 
                                                 stripeToken: "123"})
        expect(alice.follows?(bob)).to be_true
      end

      it "expires the invitation" do
        alice = Fabricate(:user)
        bob = Fabricate.build(:user)
        invitation = Fabricate(:invitation,
                               recipient_email: bob.email,
                               recipient_name: bob.full_name,
                               inviter_id: alice.id)
        UserRegistration.new(bob).register_user({invitation_token: invitation.token, 
                                                   stripeToken: "123"})
        expect(invitation.reload.token).to be_nil
      end

      it "sends out a welcome email" do
        alice = Fabricate.build(:user)
        UserRegistration.new(alice).register_user({stripeToken: "123"})
        expect(ActionMailer::Base.deliveries).not_to be_empty
      end

      it "sends the welcome email to the right recipient" do
        alice = Fabricate.build(:user)
        UserRegistration.new(alice).register_user({stripeToken: "123"})
        message = ActionMailer::Base.deliveries.last
        expect(message.to).to eq([alice.email])
      end

      it "sends a welcome email with the right content" do
        alice = Fabricate.build(:user)
        UserRegistration.new(alice).register_user({stripeToken: "123"})
        message = ActionMailer::Base.deliveries.last
        expect(message.body).to include("Welcome to MyFlix, #{alice.full_name}!")
      end
    end

    context "card is not valid" do
      before do
        charge = double(:charge, 
                        successful?: false, 
                        error_message: "Your card was declined.")
        StripeWrapper::Charge.should_receive(:create).and_return(charge)
      end

      it "does not create a new user" do
        alice = Fabricate.build(:user)
        UserRegistration.new(alice).register_user({stripeToken: "123"})
        expect(User.count).to eq(0)
      end

      it "does not send a welcome email" do
        alice = Fabricate.build(:user)
        UserRegistration.new(alice).register_user({stripeToken: "123"})
        expect(ActionMailer::Base.deliveries).to be_empty
      end

      it "does not expire the invitation" do
        alice = Fabricate(:user)
        bob = Fabricate.build(:user)
        invitation = Fabricate(:invitation,
                               recipient_email: bob.email,
                               recipient_name: bob.full_name,
                               inviter_id: alice.id)
        UserRegistration.new(bob).register_user({invitation_token: invitation.token, 
                                                 stripeToken: "123"})
        expect(invitation.reload.token).to_not be_nil
      end

      it "sets an error message" do
        alice = Fabricate.build(:user)
        registration = UserRegistration.new(alice).register_user({stripeToken: "123"})
        expect(registration.error_message).to eq("Your card was declined.")
      end
    end

    context "info is not valid" do
      it "does not save the user" do
        alice = Fabricate.build(:bad_user)
        UserRegistration.new(alice).register_user({stripeToken: "123"})
        expect(User.count).to eq(0)
      end

      it "does not attempt to charge the card" do
        alice = Fabricate.build(:bad_user)
        UserRegistration.new(alice).register_user({stripeToken: "123"})
        StripeWrapper::Charge.should_not_receive(:create)
      end

      it "does not send an email" do
        alice = Fabricate.build(:bad_user)
        UserRegistration.new(alice).register_user({stripeToken: "123"})
        expect(ActionMailer::Base.deliveries).to be_empty
      end

      it "sets an error message" do
        alice = Fabricate.build(:bad_user)
        registration = UserRegistration.new(alice).register_user({stripeToken: "123"})
        expect(registration.error_message).to eq("Please correct the following errors:")
      end
    end
  end
end