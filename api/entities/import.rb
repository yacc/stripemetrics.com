module Stripemetrics

  module Entities
    class Import < Grape::Entity
      expose :type
      expose :text, :documentation => { :type => "string", :desc => "Data import" }
      expose :time
      expose :count
      expose :status
    end
  end

end