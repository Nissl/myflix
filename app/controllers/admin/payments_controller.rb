class Admin::PaymentsController < AdminController
  def index
    @payments = PaymentDecorator.decorate_collection(
                  Payment.all.order("created_at DESC").limit(10)
                )
  end
end