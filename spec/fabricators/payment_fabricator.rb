Fabricator(:payment) do
  user_id { rand(1..10) }
  amount { 999 }
  reference_id { Faker::Lorem.characters(char_count = 15) }
end