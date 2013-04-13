require 'machinist/mongoid'

# Add your blueprints here.
#
# e.g.
#   Post.blueprint do
#     title { "Post #{sn}" }
#     body  { "Lorem ipsum..." }
#   end

User.blueprint do
  email {"yacin@stripemetrics.com"}
  livemode {"false"}
end

SdeImportDirector.blueprint do
  last_ran_at {1.day.ago}
  last_processed_ts {1.day.ago+13.hours}
end

CdeImportDirector.blueprint do
  last_ran_at {1.day.ago}
  last_processed_ts {1.day.ago+13.hours}
end

SdeImport.blueprint do
  status {"processing"}
  time {1.hour}
  count {450}   
end

Charge.blueprint do
  # Attributes here
end

Trend.blueprint do
  # Attributes here
end

Account.blueprint do
  # Attributes here
end


