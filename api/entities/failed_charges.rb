module Stripemetrics

  module Entities
    class FailedCharges < Grape::Entity
      expose :text, :documentation => { :type => "string", :desc => "A charge that was declined" }
      expose :stripe_id
      expose :invoice
      expose :failure_code
      expose :failure_message
      expose :amount
      expose :created
    end
  end

end