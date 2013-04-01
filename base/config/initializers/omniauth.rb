Rails.application.config.middleware.use OmniAuth::Builder do
  provider :stripe_connect, ENV['STRIPE_CONNECT_CLIENT_ID'], ENV['STRIPE_API_KEY'], :scope => :read_only
end