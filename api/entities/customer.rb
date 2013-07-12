module Stripemetrics

  module Entities
    class Customer < Grape::Entity
      expose :text, :documentation => { :type => "string", :desc => "A Stripe customer" }
      expose :stripe_id
      expose :email
      expose :created
      expose :canceled_at
    end
  end

end