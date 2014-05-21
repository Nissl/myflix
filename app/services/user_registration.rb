class UserRegistration
  attr_reader :error_message
  def initialize(user)
    @user = user
  end

  def register_user(params)
    if @user.valid?
      Stripe.api_key = ENV["STRIPE_API_KEY"]
      customer = StripeWrapper::Customer.create(
        :card => params[:stripeToken],
        :description => "Sign up charge for #{@user.email}",
        :user => @user
      )
      if customer.created?
        @user.customer_token = customer.customer_token
        @user.save
        handle_invitation(params[:invitation_token])
        AppMailer.registration_email(@user).deliver
        @status = :success
      else
        @error_message = customer.error_message
      end
    else
      @error_message = "Please correct the following errors:"
    end
    self
  end

  def successful?
    @status == :success
  end

  private

  def handle_invitation(invitation_token)
    invitation = Invitation.find_by(token: invitation_token)
    if invitation
      @user.follow!(invitation.inviter)
      invitation.inviter.follow!(@user)
      invitation.update_column(:token, nil)
    end
  end
end