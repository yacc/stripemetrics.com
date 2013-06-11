class ImportDirector
  include Mongoid::Document

  field :last_ran_at, type: DateTime
  field :oldest_ts, type: Integer
  field :newest_ts, type: Integer

  belongs_to :user

end
