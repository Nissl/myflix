StripeWrapper.set_api_key

StripeEvent.configure do |events|
  events.subscribe 'charge.succeeded' do |event|
    user = User.find_by(customer_token: event.data.object.card.customer)
    user.update_column(:account_active, true)
    Payment.create(user_id: user.id, 
                   amount: event.data.object.amount,
                   reference_id: event.data.object.id)
  end

  events.subscribe 'charge.failed' do |event|
    user = User.find_by(customer_token: event.data.object.card.customer)
    user.update_column(:account_active, false)
    AppMailer.locked_account_email(user).deliver
  end
end