require 'spec_helper'

describe QueueItemsController do  

  describe "GET index" do
    before do
      set_current_user
      create_queue_items
    end

    context "user authenticated" do
      before do
        get :index
      end

      it "sets @queue_items variable, ordered by position" do
        expect(assigns(:queue_items)).to eq([queue_item(1), queue_item(2), queue_item(3)])
      end

      it "renders index template, my_queue page" do
        expect(response).to render_template :index
      end
    end

    context "user not authenticated" do
      before do
        clear_current_user
        get :index
      end

      it "does not set @queue_items variable" do
        expect(assigns(:queue_items)).to eq(nil)
      end
      
      it_behaves_like "require_login"
    end
  end

  describe "POST create" do
    before do
      set_current_user
    end

    context "user authenticated" do
      it "creates a queue item" do
        fabricate_video_and_post_to_create
        expect(QueueItem.count).to eq(1)
      end

      it "creates a queue item that is associated with the user" do
        fabricate_video_and_post_to_create
        expect(QueueItem.first.user).to eq(User.first)
      end

      it "creates a queue item that is associated with the video" do
        fabricate_video_and_post_to_create
        expect(QueueItem.first.video).to eq(Video.first)
      end

      it "sets the position of the queue item to the end of the queue" do
        video = Fabricate(:video)
        video2 = Fabricate(:video)
        queue_item1 = Fabricate(:queue_item, position: 1, video_id: video.id, user_id: current_user.id)
        post :create, video_id: video2.id
        queue_item2 = QueueItem.where(video_id: video2.id, user_id: current_user.id).first
        expect(queue_item2.reload.position).to eq(2)
      end

      it "redirects to my_queue index page" do
        fabricate_video_and_post_to_create
        expect(response).to redirect_to my_queue_path
      end

      it "does not add the video to the queue if the video is already in the user's queue" do
        video = Fabricate(:video)
        queue_item1 = Fabricate(:queue_item, position: 1, video_id: video.id, user_id: current_user.id)
        post :create, video_id: video.id
        expect(current_user.queue_items.count).to eq(1)
      end
    end

    context "user not authenticated" do
      before do
        clear_current_user
        fabricate_video_and_post_to_create
      end

      it "does not add the video to the queue" do
        expect(QueueItem.count).to eq(0)
      end
      
      it_behaves_like "require_login"
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      set_current_user
      create_queue_items
    end

    it "deletes the selected item from queue_items if in user's queue" do
      delete :destroy, id: 1
      expect(current_user.queue_items.count).to eq(2)
    end

    it "does not delete the selected item if not in user's queue" do
      bob = Fabricate(:user)
      Fabricate(:queue_item, user_id: bob.id, video_id: 1, position: 1)
      delete :destroy, id: 4
      expect(bob.queue_items.count).to eq(1)
    end

    it "does not delete other videos" do
      delete :destroy, id: 1
      expect(current_user.queue_items.first.id).to eq(2)
    end

    it "normalizes the queue positions of lower ranked items" do
      delete :destroy, id: 1
      expect(current_user.queue_items.first.position).to eq(1)
      expect(current_user.queue_items.last.position).to eq(2)
    end

    it "does not change the queue position of higher ranked items" do
      delete :destroy, id: 2
      expect(current_user.queue_items.count).to eq(2)
      expect(current_user.queue_items.first.position).to eq(1)
    end

    it_behaves_like "redirect_to_my_queue" do
      let(:action) { delete :destroy, id: 1 }
    end

    context "user not authenticated" do
      before do
        clear_current_user
        delete :destroy, id: 1
      end

      it "does not delete the selected video from user_videos" do
        expect(User.first.queue_items.count).to eq(3)
      end

      it_behaves_like "require_login"
    end
  end
  
  describe "POST update_queue" do
    context "with valid inputs" do
      let(:alice) { Fabricate(:user) }
      let(:video1) { Fabricate(:video) }
      let(:video2) { Fabricate(:video) }
      let(:video3) { Fabricate(:video) }
      let!(:queue_item1) { Fabricate(:queue_item, user_id: alice.id, video_id: video1.id, position: 1) }
      let!(:queue_item2) { Fabricate(:queue_item, user_id: alice.id, video_id: video2.id, position: 2) }
      let!(:queue_item3) { Fabricate(:queue_item, user_id: alice.id, video_id: video3.id, position: 3) }

      before(:each) do 
        session[:user_id] = alice.id
      end

      it "redirects to the my queue page" do
        post :update_queue, queue_items: [{id: "1", position: "1"}]
        expect(response).to redirect_to my_queue_path
      end

      it "updates queue positions" do
        post :update_queue, queue_items: [{id: "1", position: "3"}, 
                                          {id: "2", position: "2"}, 
                                          {id: "3", position: "1"}]
        expect(alice.queue_items).to eq([queue_item3, queue_item2, queue_item1])
        # reload is necessary or the database update in the controller won't impact the variables
        # welp, there's two hours of my life gone
        expect(queue_item1.reload.position).to eq(3)
        expect(queue_item2.reload.position).to eq(2)
        expect(queue_item3.reload.position).to eq(1)
      end

      it "normalizes the position numbers to start with 1" do
        post :update_queue, queue_items: [{id: "1", position: "4"}, 
                                          {id: "2", position: "3"}, 
                                          {id: "3", position: "2"}]
        expect(alice.queue_items.map(&:position)).to eq([1, 2, 3])
      end

      it "moves an item to the end of the queue if one position input off end of queue" do
        post :update_queue, queue_items: [{id: "1", position: "4"}, 
                                          {id: "2", position: "2"}, 
                                          {id: "3", position: "1"}]
        expect(queue_item1.reload.position).to eq(3)
        expect(queue_item2.reload.position).to eq(2)
        expect(queue_item3.reload.position).to eq(1)                                         
      end
    end

    context "with invalid inputs" do
        let(:alice) { Fabricate(:user) }
        let(:video1) { Fabricate(:video) }
        let(:video2) { Fabricate(:video) }
        let(:video3) { Fabricate(:video) }
        let!(:queue_item1) { Fabricate(:queue_item, user_id: alice.id, video_id: video1.id, position: 1) }
        let!(:queue_item2) { Fabricate(:queue_item, user_id: alice.id, video_id: video2.id, position: 2) }
        let!(:queue_item3) { Fabricate(:queue_item, user_id: alice.id, video_id: video3.id, position: 3) }

        before(:each) do 
          session[:user_id] = alice.id
        end

      context "with non-integer input" do
        before(:each) do
          post :update_queue,  queue_items: [{id: "1", position: "3"}, 
                                            {id: "2", position: "2"}, 
                                            {id: "3", position: "1.5"}]
        end

        it "redirects to the my queue page" do
          expect(response).to redirect_to my_queue_path
        end

        it "sets a flash error message" do
          expect(flash[:danger]).to eq("Non-integer order numbers entered") 
        end

        it "does not change any queue item positions" do
          expect(alice.queue_items).to eq([queue_item1, queue_item2, queue_item3])
        end
      end

      context "with duplicate positions input" do
        before(:each) do
          post :update_queue,  queue_items: [{id: "1", position: "3"}, 
                                            {id: "2", position: "2"}, 
                                            {id: "3", position: "2"}]
        end

        it "redirects to the my queue page" do

          expect(response).to redirect_to my_queue_path
        end

        it "sets a flash error message" do
          expect(flash[:danger]).to eq("Non-unique order numbers entered") 
        end

        it "does not change any queue positions" do
          expect(alice.queue_items).to eq([queue_item1, queue_item2, queue_item3])             
        end
      end
    end

    context "with unauthenticated users"
      let(:alice) { Fabricate(:user) }
      let(:video1) { Fabricate(:video) }
      let(:video2) { Fabricate(:video) }
      let(:video3) { Fabricate(:video) }
      let!(:queue_item1) { Fabricate(:queue_item, user_id: alice.id, video_id: video1.id, position: 1) }
      let!(:queue_item2) { Fabricate(:queue_item, user_id: alice.id, video_id: video2.id, position: 2) }
      let!(:queue_item3) { Fabricate(:queue_item, user_id: alice.id, video_id: video3.id, position: 3) }
      
      before(:each) do
        post :update_queue, queue_items: [{id: "1", position: "3"}, 
                                          {id: "2", position: "2"}, 
                                          {id: "3", position: "1"}]
      end

      it "redirects to login page" do
        expect(response).to redirect_to login_path
      end

      it "does not change any queue positions" do
        expect(alice.queue_items).to eq([queue_item1, queue_item2, queue_item3])
      end

    context "with queue items that do not belong to user" do
      let(:alice) { Fabricate(:user) }
      let(:bob) { Fabricate(:user) }
      let(:video1) { Fabricate(:video) }
      let(:video2) { Fabricate(:video) }
      let(:video3) { Fabricate(:video) }
      let!(:queue_item1) { Fabricate(:queue_item, user_id: alice.id, video_id: video1.id, position: 1) }
      let!(:queue_item2) { Fabricate(:queue_item, user_id: alice.id, video_id: video2.id, position: 2) }
      let!(:queue_item3) { Fabricate(:queue_item, user_id: alice.id, video_id: video3.id, position: 3) }

      before(:each) do
        session[:user_id] = bob.id
        post :update_queue, queue_items: [{id: "1", position: "3"}, 
                                          {id: "2", position: "2"}, 
                                          {id: "3", position: "1"}]
      end

      it "redirects to the my queue page" do 
        expect(response).to redirect_to my_queue_path
      end

      it "does not change any queue positions" do
        expect(alice.queue_items).to eq([queue_item1, queue_item2, queue_item3])
      end
    end
  end
end