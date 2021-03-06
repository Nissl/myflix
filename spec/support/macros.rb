def set_current_user(user=nil)
  session[:user_id] = (user || Fabricate(:user)).id
end

def current_user
  User.find(session[:user_id])
end

def clear_current_user
  session[:user_id] = nil
end

def set_current_admin(admin=nil)
  session[:user_id] = (admin || Fabricate(:admin)).id
end

def sign_in_user(a_user=nil)
  user = a_user || Fabricate(:user)
  visit login_path
  fill_in 'Email Address', with: user.email
  fill_in 'Password', with: user.password
  click_button 'Sign in'
end

def sign_out_user(user)
  visit logout_path
end

def create_queue_items
  video1 = Fabricate(:video)
  video2 = Fabricate(:video)
  video3 = Fabricate(:video)
  queue_item1 = Fabricate(:queue_item, user_id: current_user.id, video_id: video1.id, position: 1)
  queue_item2 = Fabricate(:queue_item, user_id: current_user.id, video_id: video2.id, position: 2)
  queue_item3 = Fabricate(:queue_item, user_id: current_user.id, video_id: video3.id, position: 3)
end

def fabricate_video_and_post_to_create
  video = Fabricate(:video)
  post :create, video_id: video.id
end

def fabricate_queue_item_with_category
  user = Fabricate(:user)
  category = Fabricate(:category)
  video = Fabricate(:video, category_id: category.id)
  queue_item = Fabricate(:queue_item, video_id: video.id, user_id: user.id)
end

def queue_item(id)
  QueueItem.find(id)
end

def confirm_user_registered(user)
  expect(page).to have_content("Welcome, #{user.full_name}")
end

def confirm_user_not_registered
  expect(page).to have_content("Something was wrong with the email or password you entered. Please try again.")
end

def fill_in_user_info(user)
  fill_in "Full Name", with: user.full_name
  fill_in "Password", with: user.password
  fill_in "Email Address", with: user.email
end

def fill_in_valid_credit_card_info
  fill_in "Credit Card Number", with: "4242424242424242"
  fill_in "Security Code", with: "123"
  select "6 - June", from: "date_month"
  select "2017", from: "date_year"
end

def fill_in_invalid_credit_card_info
  fill_in "Credit Card Number", with: "123"
  fill_in "Security Code", with: "123"
  select "6 - June", from: "date_month"
  select "2017", from: "date_year"
end

def fill_in_declined_credit_card_info
  fill_in "Credit Card Number", with: "4000000000000002"
  fill_in "Security Code", with: "123"
  select "6 - June", from: "date_month"
  select "2017", from: "date_year"
end

def click_register
  click_button "Register"
end

def confirm_successful_registration(user)
  expect(page).to have_content("You registered! Welcome, #{user.full_name}!")
end
