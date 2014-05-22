require 'spec_helper'

describe SessionsController do
  describe "GET new" do
    it "redirects authenticated user to home" do
      session[:user_id] = Fabricate(:user).id
      get :new
      expect(response).to redirect_to home_path
    end

    it "renders the new template if no user authenticated" do
      get :new
      expect(response).to render_template :new
    end
  end

  describe "POST create" do
    context "with valid login credentials, active account" do
      before do
        alice = Fabricate(:user)
        post :create, email: alice.email, password: alice.password
      end

      it "puts the signed in user in the session" do
        expect(session[:user_id]).to eq(User.first.id)
      end

      it "sets a success notice" do
        expect(flash[:success]).not_to be_blank
      end

      it "redirects to the home page" do
        expect(response).to redirect_to home_path
      end
    end

    context "with valid login credentials, locked account" do
      it "does not put the user into the session" do
        alice = Fabricate(:user, account_active: false)
        post :create, email: alice.email, password: alice.password
        expect(session[:user_id]).to be_nil
      end

      it "flashes an error message indicating that the account is locked" do
        alice = Fabricate(:user, account_active: false)
        post :create, email: alice.email, password: alice.password
        expect(flash[:danger]).to eq("Your account has been locked.")
      end
      
      it_behaves_like "requires login" do
        let(:user) { Fabricate(:user, account_active: false) }
        let(:action) { post :create, email: user.email, password: user.password } 
      end
    end

    context "with invalid login credentials" do
      it "does not put the user into the session" do
        alice = Fabricate(:user)
        post :create, email: alice.email, password: alice.password + "asdfsakd"
        expect(session[:user_id]).to be_nil
      end

      it "flashes an error message" do
        alice = Fabricate(:user)
        post :create, email: alice.email, password: alice.password + "asdfsakd"
        expect(session[:user_id]).to be_nil
        expect(flash[:danger]).not_to be_blank
      end

      it_behaves_like "requires login" do
        let(:user) { Fabricate(:user) }
        let(:action) { post :create, email: user.email, password: user.password + "asdfsakd" } 
      end
    end
  end

  describe "GET destroy" do
    before do
      session[:user_id] = Fabricate(:user).id
      get :destroy
    end

    it "sets a success message to flash" do
      expect(flash[:success]).not_to be_blank
    end

    it "clears the user session" do
      expect(session[:user_id]).to be_nil
    end

    it "redirects to the root path" do
      expect(response).to redirect_to root_path
    end
  end
end