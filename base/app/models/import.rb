# objects are returned in sorted order, with the most recent charges appearing first.
# 
# objects [o1,o2,o3 .. o13 .........o22.................. o34000..... o100000]
#                       ^            ^                      ^
#                       | <-- 10 --> |                      |
#                     start_at    last_imported_ts       end_at
#
# sometimes (often) an import will import less objects than contained in the 
# intervaled asked for (b/c of the limitation on object returned by the API)
#
class Import
  include Mongoid::Document
  include Mongoid::Timestamps::Created::Short

  field :status,   type: Symbol,  default: :processing   #  status of the job
  field :time,     type: Integer  #  elapsed time to complete the import
  field :count,    type: Integer, default: 0
  field :mode,     type: Symbol,  default: :from_stripe
  field :start_at, type: DateTime
  field :end_at,   type: DateTime
  field :file,     type: String
  field :limit,    type: Integer, default: 10 #limit on how many records are imported
  field :initial,  type: Boolean
  field :last_imported_ts, type: DateTime
  field :token,    type: String

  validates_inclusion_of :status, in: [ :processing, :failed, :succeeded ]
  validates_inclusion_of :mode,   in: [ :from_file, :from_stripe ]
  validates_presence_of  :file,   :if => :from_file?

  belongs_to :import_director   # orchestrates and aggregates stats about imports
  belongs_to :user

  after_create :enqueue

  def from_stripe_api?
    self.mode == :from_stripe
  end

  def from_file?
    self.mode == :from_file
  end

  # TODO: replace Charge by Object
  # TODO: actually create the objects
  # TODO: track API elapsed time 
  def run!
    start_time = Time.now
    if from_file?
      raise "Import from file failed: file does not exits or wrong path #{self.file}" unless File.exists?(self.file)
      #TODO: use a stream enabled parser for large files
      objects = JSON.parse(File.read(self.file))
      self.count  = objects.empty? ? 0 : objects.size
      if self.count
        self.persiste!(objects)
        self.last_imported_ts = objects.last['created']
      end
    else
      self.token ||= self.user.token
      objects = self.get_from_stripe
      self.count  = objects.count ? objects.data.size : 0
      if objects.count > 0
        self.persiste!(objects)
        self.last_imported_ts = objects.data.last.created
      end
    end
    self.time = (start_time-Time.now).to_i
    self.save
  end

  def did_not_import_all_objects_in_interval?
    self.count == self.limit 
  end

  protected

  def enqueue
    Resque.enqueue(ImportObjects,self._id)   
  end

end
