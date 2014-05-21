StripeWrapper.set_api_key

StripeEvent.configure do |events|
  events.subscribe 'charge.succeeded' do |event|
    Payment.create(user_id: User.find_by(customer_token: event.data.object.card.customer).id, 
                   amount: event.data.object.amount,
                   reference_id: event.data.object.id)
  end
end