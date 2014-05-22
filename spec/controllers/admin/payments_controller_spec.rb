require 'spec_helper'
  
describe Admin::PaymentsController do
  describe "GET index" do
    it_behaves_like "requires login" do
      let(:user) { Fabricate(:user) }
      let(:action) { get :index }
    end

    it_behaves_like "requires admin" do
      let(:action) { get :index }
    end

    it "sets the payments variable" do
      set_current_admin
      payment1 = Fabricate(:payment)
      get :index
      expect(assigns(:payments)).to eq([payment1])
    end

    it "orders the payments by created_at in descending order" do
      set_current_admin
      payment1 = Fabricate(:payment)
      payment2 = Fabricate(:payment)
      get :index
      expect(assigns(:payments)).to eq([payment2, payment1])
    end

    it "limits the payments to 10" do
      set_current_admin
      11.times do
        Fabricate(:payment)
      end
      get :index
      expect(assigns(:payments)).to have_exactly(10).items
    end
  end
end