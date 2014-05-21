class PaymentDecorator < ApplicationDecorator
  delegate_all

  def amount_formatted
    amount_string = object.amount.to_s
    amt_str_len = amount_string.length
    cents = "#{amount_string[(amt_str_len - 2)..(amt_str_len - 1)]}"
    if amt_str_len == 1
      "$0.0#{amount_string}"
    elsif amt_str_len == 2
      "$0.#{cents}"
    else
      "$#{amount_string[0..(amt_str_len - 3)]}.#{cents}"
    end
  end
end