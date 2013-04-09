module Stripemetrics

  module Entities
    class ImportDirector < Grape::Entity
      expose :type
      expose :text, :documentation => { :type => "string", :desc => "Status of all data imports" }
      expose :last_ran_at
      expose :last_processed_ts
      expose :imports, :using => Stripemetrics::Entities::Import, :as => :imports
    end
  end

end