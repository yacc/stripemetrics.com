module Stripemetrics

  module Entities
    class Metric < Grape::Entity
      expose :_type
      expose :text, :documentation => { :type => "string", :desc => "Metric" }
      expose :name
      expose :desc
      expose :this_month
      expose :last_month
      expose :this_month_ts
      expose :last_month_ts
      expose :change
      expose :tsm_avrg
      expose :goal
    end
  end

end