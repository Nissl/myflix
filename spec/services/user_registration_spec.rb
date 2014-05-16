require 'spec_helper'      

describe UserRegistration do
  context "card is valid" do
    after { ActionMailer::Base.deliveries.clear }
    before do
      charge = double(:charge, successful?: true)
      StripeWrapper::Charge.stub(:create).and_return(charge)
    end

    it "creates a new user" do
      alice = Fabricate.build(:user)
      UserRegistration.create(alice, params: {stripeToken: "123"})
      expect(alice.save).to be_true
    end

    it "sends out a welcome email" do
      alice = Fabricate.build(:user)
      UserRegistration.create(alice, params: {stripeToken: "123"})
      expect(ActionMailer::Base.deliveries).not_to be_empty
    end

    it "sends the welcome email to the right recipient" do
      alice = Fabricate.build(:user)
      UserRegistration.create(alice, params: {stripeToken: "123"})
      message = ActionMailer::Base.deliveries.last
      expect(message.to).to eq([alice.email])
    end

    it "sends a welcome email with the right content" do
      alice = Fabricate.build(:user)
      UserRegistration.create(alice, params: {stripeToken: "123"})
      message = ActionMailer::Base.deliveries.last
      expect(message.body).to include("Welcome to MyFlix, #{alice.full_name}!")
    end

    it "makes the user follow the inviter, if invited" do
      alice = Fabricate(:user)
      bob = Fabricate.build(:user)
      invitation = Fabricate(:invitation,
                             recipient_email: bob.email,
                             recipient_name: bob.full_name,
                             inviter_id: alice.id)
      UserRegistration.create(bob, 
                              {invitation_token: invitation.token, 
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
      UserRegistration.create(bob, 
                              {invitation_token: invitation.token, 
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
      UserRegistration.create(bob, 
                              {invitation_token: invitation.token, 
                               stripeToken: "123"})
      expect(invitation.reload.token).to be_nil
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
      UserRegistration.create(alice, params: {stripeToken: "123"})
      expect(User.count).to eq(0)
    end

    it "does not send a welcome email" do
      alice = Fabricate.build(:user)
      UserRegistration.create(alice, params: {stripeToken: "123"})
      expect(ActionMailer::Base.deliveries).to be_empty
    end

    it "does not expire the invitation" do
      alice = Fabricate(:user)
      bob = Fabricate.build(:user)
      invitation = Fabricate(:invitation,
                             recipient_email: bob.email,
                             recipient_name: bob.full_name,
                             inviter_id: alice.id)
      UserRegistration.create(bob, 
                              {invitation_token: invitation.token, 
                               stripeToken: "123"})
      expect(invitation.reload.token).to_not be_nil
    end
  end
end