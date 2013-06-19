module Stripemetrics

  module Entities
    class Imports < Grape::Entity
      expose :type
      expose :text, :documentation => { :type => "string", :desc => "Status of all imports" }
      expose :last_ran_at
      expose :last_processed_ts
      expose :imports, :using => Stripemetrics::Entities::Import, :as => :imports
    end
  end

end