require 'spec_helper'

describe VideoDecorator do
  describe "average_rating" do
    context "no ratings exist" do
      it "returns '-' if no ratings exist" do
        video = Fabricate(:video).decorate
        expect(video.average_rating).to eq('-')
      end
    end

    context "one rating exists" do
      it "returns the rating if one rating exists" do
        video = Fabricate(:video).decorate
        rating = rand(1..5).to_f
        review = Fabricate(:review, rating: rating, video_id: Video.first.id)
        expect(video.average_rating).to eq(rating.to_s)
      end
    end

    context "multiple ratings exist" do
      it "returns the average rating, rounded to one decimal place" do
        video = Fabricate(:video).decorate
        sum, review_count = 0, 15
        user_id = 1
        review_count.times do
          rating = rand(1..5).to_f
          review = Fabricate(:review, rating: rating, video_id: Video.first.id, user_id: user_id)
          user_id += 1
          sum += rating
        end
        expect(video.average_rating).to eq((sum / review_count).round(1).to_s)
      end
    end
  end
end