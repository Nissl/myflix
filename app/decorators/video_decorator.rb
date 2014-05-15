class VideoDecorator < ApplicationDecorator
  delegate_all

  def decorator
    VideoDecorator.new(self)
  end

  def average_rating
    return 'N/A' if object.reviews.count == 0
    "#{object.reviews.average(:rating).round(1).to_s} / 5"
  end
end
