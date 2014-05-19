module StripeWrapper
  class Charge
    attr_reader :response, :status

    def initialize(options={})
      @response = options[:response]
      @status = options[:status]
    end

    def self.create(options={})
      StripeWrapper.set_api_key
      begin
        response = Stripe::Charge.create(amount: options[:amount], 
                                         currency: 'usd', 
                                         card: options[:card],
                                         description: options[:description])
        new(response: response, status: "success")
      rescue Stripe::CardError => e
        new(response: e, status: "error")
      end
    end

    def successful?
      @status == "success"
    end

    def error_message
      @response.message
    end
  end

  class Customer
    attr_reader :response, :status, :stripe_id
    
    def initialize(options={})
      @response = options[:response]
      @status = options[:status]
      @stripe_id = options[:stripe_id]
    end

    def self.create(options={})
      begin
        response = Stripe::Customer.create(
          card: options[:card],
          email: options[:user].email,
          plan: "basic"  
        )
        new(
          response: response, 
          status: "success", 
          stripe_id: response.id
        )
      rescue Stripe::CardError => e
        new(response: e, status: "error")
      end
    end

    def created?
      @status == "success"
    end

    def error_message
      @response.message
    end
  end

  def self.set_api_key
    Stripe.api_key = ENV['STRIPE_API_KEY']
  end
end
