require 'spec_helper'

describe Video do
  it { should belong_to(:category) }
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:description) }

  describe "search_by_title" do
    it "returns an empty array if string does not match any titles" do
      video1 = Fabricate(:video, title: "Futurama")
      video2 = Fabricate(:video, title: "Back to Future")
      search = "unmatched_title"
      expect(Video.search_by_title(search)).to eq([])
    end

    it "returns a one-video array if the string exactly matches one title" do
      video1 = Fabricate(:video, title: "Futurama")
      video2 = Fabricate(:video, title: "Back to Future")
      search = "futurama"
      expect(Video.search_by_title(search)).to eq([video1])
    end

    it "returns an array of one video for a partial match" do
      video1 = Fabricate(:video, title: "Futurama")
      video2 = Fabricate(:video, title: "Family Guy")
      video3 = Fabricate(:video, title: "Family Comedy")
      search = "futur"
      expect(Video.search_by_title(search)).to eq([video1])
    end

    it "returns an array of all matches, ordered by created_at" do
      video1 = Fabricate(:video, title: "Futurama")
      video2 = Fabricate(:video, title: "Family Guy", created_at: 1.day.ago)
      video3 = Fabricate(:video, title: "Family Comedy")
      search = "family"
      expect(Video.search_by_title(search)).to eq([video3, video2])
    end

    it "returns an empty array when search term is empty string" do
      video1 = Fabricate(:video, title: "Futurama")
      video2 = Fabricate(:video, title: "Family Guy")
      video3 = Fabricate(:video, title: "Family Comedy")
      search = ""
      expect(Video.search_by_title(search)).to eq([])
    end
  end
end