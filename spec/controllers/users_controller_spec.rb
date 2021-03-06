require 'spec_helper'

describe UsersController do
  describe "GET new" do
    it "sets @user to User.new" do
      get :new 
      expect(assigns(:user)).to be_instance_of(User)
    end
  end

  describe "GET new_with_invitation_token" do
    context "valid token" do
      it "sets @user with attributes from the invitation" do
        invitation = Fabricate(:invitation)
        get :new_with_invitation_token, token: invitation.token
        expect(assigns(:user).full_name).to eq(invitation.recipient_name)
        expect(assigns(:user).email).to eq(invitation.recipient_email)
      end

      it "renders the registration page" do
        invitation = Fabricate(:invitation)
        get :new_with_invitation_token, token: invitation.token
        expect(response).to render_template :new
      end

      it "sets @invitation_token to the invitation's token" do
        invitation = Fabricate(:invitation)
        get :new_with_invitation_token, token: invitation.token
        expect(assigns(:invitation_token)).to eq(invitation.token)
      end
    end

    context "invalid token" do 
      it "redirects to expired token path" do 
        invitation = Fabricate(:invitation)
        get :new_with_invitation_token, token: "bad_token"
        expect(response).to redirect_to expired_token_path
      end
    end
  end

  describe "POST create", js: true do
    context "personal information is valid" do
      it "delegates the user registration to UserRegistration service object" do
        registration = double(:registration, successful?: true)
        UserRegistration.any_instance.should_receive(:register_user).and_return(registration)
        post :create, user: Fabricate.attributes_for(:user)
      end

      context "registration is valid" do
        before do
          registration = double(:registration, successful?: true)
          UserRegistration.any_instance.stub(:register_user).and_return(registration)
        end

        it "sets a flash success message" do
          post :create, user: {email: 'joe@example.com', password: 'password', full_name: "Joe Doe"}
          expect(flash[:success]).to eq("You registered! Welcome, Joe Doe!")
        end

        it "redirects to login page" do
          post :create, user: Fabricate.attributes_for(:user)
          expect(response).to redirect_to login_path
        end
      end

      context "registration is invalid" do
        before do
          registration = double(:registration, 
                                successful?: false, 
                                error_message: "Your card was declined.")
          UserRegistration.any_instance.stub(:register_user).and_return(registration)
        end

        it "sets a flash danger message" do
          post :create, user: Fabricate.attributes_for(:user)
          expect(flash[:danger]).to eq("Your card was declined.")
        end

        it "renders the new template" do
          post :create, user: Fabricate.attributes_for(:user)
          expect(response).to render_template :new
        end
      end
    end
  end

  describe "GET show" do
    before do
      alice = Fabricate(:user)
      bob = Fabricate(:user)
    end

    it "sets @user" do
      set_current_user(User.find(1))
      get :show, id: User.find(2).id 
      expect(assigns(:user)).to be_instance_of(User)
    end

    context "unauthenticated user" do
      before { get :show, id: User.find(2).id }

      it "does not set @user" do
        expect(assigns(:user)).not_to be_instance_of(User)
      end

      it_behaves_like "requires login" do
        let(:user) { User.find(2) }
        let(:action) { get :show, id: User.find(2).id }   
      end
    end
  end
end