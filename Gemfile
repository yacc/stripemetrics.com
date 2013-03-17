source 'https://rubygems.org'
gem 'rails', '3.2.12'

# stripe support
gem "stripe", :git => 'https://github.com/stripe/stripe-ruby'

# db
gem "mongoid", ">= 3.1.1"

# jobs
gem 'resque', :require => 'resque/server'

# auth and roles
gem "omniauth", ">= 1.1.3"
gem "omniauth-stripe-connect"
gem "cancan", ">= 1.6.8"
gem "rolify", ">= 3.2.0"

# application 
gem "figaro", ">= 0.5.3"
gem "multipart-post", ">= 1.2.0"

# view layer
gem 'jquery-rails'
gem "haml-rails", ">= 0.4"
gem "bootstrap-sass", ">= 2.3.0.0"
gem "simple_form", ">= 2.0.4"

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

group :production do
	gem "thin", ">= 1.5.0"
end

group :development do
	gem "html2haml", ">= 1.0.1"
	gem "quiet_assets", ">= 1.0.1"
	gem "better_errors", ">= 0.6.0"
	gem "binding_of_caller", ">= 0.7.1", :platforms => [:mri_19, :rbx]
	gem "rspec-rails", ">= 2.12.2"
end

group :test do
	gem "rspec-rails", ">= 2.12.2"	
	gem "capybara", ">= 2.0.2"
	gem "database_cleaner", ">= 0.9.1"
	gem "mongoid-rspec", ">= 1.6.0"
	gem "email_spec", ">= 1.4.0"
	gem "machinist", ">= 2.0"
	gem "machinist_mongo",  :git => 'https://github.com/nmerouze/machinist_mongo.git',
                          :require => 'machinist/mongoid',
                          :branch => 'machinist2'
end

