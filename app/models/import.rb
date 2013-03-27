class Import
  include Mongoid::Document
  include Mongoid::Timestamps::Created::Short

  field :status, type: String   #  status of the job
  field :time,   type: DateTime #  elapsed time to complete the import
  field :count,  type: Integer  #  how many records where imported

  validates_inclusion_of :status, in: [ "processing","failed","succeeded" ]
  belongs_to :import_director   # aggregates stats about imports

end
