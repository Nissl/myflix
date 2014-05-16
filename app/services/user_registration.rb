class UserRegistration
  attr_reader :charge
  def initialize(charge)
    @charge = charge
  end

  def self.create(user, params)
    Stripe.api_key = ENV["STRIPE_API_KEY"]
    charge = StripeWrapper::Charge.create(
      :amount => 999, 
      :card => params[:stripeToken],
      :description => "Sign up charge for #{user.email}"
    )
    if charge.successful?
      user.save
      handle_invitation(user, params[:invitation_token])
      AppMailer.registration_email(user).deliver
    end
    new(charge)
  end

  def self.handle_invitation(user, invitation_token)
    invitation = Invitation.find_by(token: invitation_token)
    if invitation
      user.follow!(invitation.inviter)
      invitation.inviter.follow!(user)
      invitation.update_column(:token, nil)
    end
  end
end