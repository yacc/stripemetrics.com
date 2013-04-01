class ImportDirector
  include Mongoid::Document

  field :last_ran_at, type: DateTime
  field :last_processed_ts, type: Integer

  belongs_to :user
  has_many   :imports


end
