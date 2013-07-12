module Stripemetrics

  module Entities
    class Customers < Grape::Entity
      expose :text, :documentation => { :type => "string", :desc => "Stripe customers" }
      expose :customers, :using => Stripemetrics::Entities::Customer, :as => :customers
    end
  end

end