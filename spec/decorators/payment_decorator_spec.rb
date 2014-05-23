require 'spec_helper'

describe PaymentDecorator do
  describe "#amount_formatted" do
    it "returns a formatted string of the amount with a $ sign before and a . place" do
      payment = Fabricate(:payment, amount: 999).decorate
      expect(payment.amount_formatted).to eq("$9.99")
    end

    it "adds a zero if the amound is less than $1" do
      payment = Fabricate(:payment, amount: 99).decorate
      expect(payment.amount_formatted).to eq("$0.99")
    end

    it "adds two zeros if the amount is less than $0.10" do
      payment = Fabricate(:payment, amount: 9).decorate
      expect(payment.amount_formatted).to eq("$0.09")
    end
  end
end