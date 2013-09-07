class User
  include Mongoid::Document
  include Mongoid::Timestamps::Created::Short
  include Billable

  MAX_IMPORTS      = 10
  # John and Patrick first started working on Stripe in early 2010.
  BEGINING_OF_TIME = Time.parse('01/01/2010')

  field :provider, type: String
  field :uid,      type: String
  field :email,    type: String
  field :password_hash, :type => String
  field :livemode, type: Boolean
  field :api_token,    type: String
  field :token,    type: String
  field :token_expires, type: Boolean
  field :admin, type: Boolean, default: false

  # validates_uniqueness_of :email, :message => "already in use"

  has_many :customers, dependent: :delete
  has_many :charges, dependent: :delete
  has_many :charge_imports, dependent: :delete
  has_many :customer_imports, dependent: :delete
  has_many :sde_imports, dependent: :delete
  has_many :cde_imports, dependent: :delete

  # aggregated data
  has_one  :acquisition_trend, dependent: :delete, autobuild: true
  has_one  :cancellation_trend, dependent: :delete, autobuild: true
  has_one  :paid_charge_count_trend , dependent: :delete, autobuild: true
  has_one  :failed_charge_count_trend, dependent: :delete, autobuild: true
  has_one  :paid_charge_volume_trend , dependent: :delete, autobuild: true
  has_one  :failed_charge_volume_trend, dependent: :delete, autobuild: true

  # metrics
  has_one  :revenue_metric, dependent: :delete, autobuild: true
  has_one  :lost_revenue_metric, dependent: :delete, autobuild: true
  has_one  :acquisition_metric, dependent: :delete, autobuild: true
  has_one  :cancellation_metric, dependent: :delete, autobuild: true

  # cohort
  has_one  :cohort, dependent: :delete, autobuild: true

  embeds_one   :account
  embeds_one   :stat, autobuild: true

  attr_accessible :provider, :uid, :name, :email, :livemode, :token, :token_expires
  attr_accessor :password

  index({ email: 1 }, { unique: true, background: true })
  index({ api_token: 1 }, { unique: true, background: true })

  before_create :generate_api_token
  after_create  :schedule_imports
  before_save   :encrypt_password


  def self.create_with_omniauth(auth)
    new_user = {provider:auth['provider'], uid:auth['uid']}
    if auth['info']
      new_user["livemode"] = auth['info']['livemode'] || false
    end
    if auth['credentials']
      new_user["token"]         = auth['credentials']['token'] || ''
      new_user["token_expires"] = auth['credentials']['expires'] || true
    end
    logger.info "YYY: New user from Stripe #{new_user}"
    User.create! new_user
  end

  def self.authenticate email, password
    user = where(:email => email).first
    if user && user.saved_password == password
      user
    else
      nil
    end
  end

  def saved_password
    @saved_password ||= BCrypt::Password.new(self.password_hash)
  end

  def encrypt_password
    if password.present?
    @saved_password = BCrypt::Password.create(password)
    self.password_hash = @saved_password
    self.password = nil
    end
  end

  def refresh_data
    # get the timestamp of the last imported object
    last_charge_import   = self.charge_imports.asc(:start_at).last.start_at
    last_customer_import = self.customer_imports.asc(:start_at).last.start_at
    last_cde_import      = self.cde_imports.asc(:start_at).last.start_at
    last_sde_import      = self.sde_imports.asc(:start_at).last.start_at
    # schedule new imports    
    self.charge_imports.create(  start_at:Time.now,end_at:last_charge_import,token:self.token,limit:MAX_IMPORTS)        
    self.customer_imports.create(start_at:Time.now,end_at:last_customer_import,token:self.token,limit:MAX_IMPORTS)
    self.cde_imports.create(     start_at:Time.now,end_at:last_cde_import,token:self.token,limit:MAX_IMPORTS)        
    self.sde_imports.create(     start_at:Time.now,end_at:last_sde_import,token:self.token,limit:MAX_IMPORTS)        
  end

  def refresh_metrics
    self.revenue_metric.refresh!
    self.lost_revenue_metric.refresh!
    self.acquisition_metric.refresh!
    self.cancellation_metric.refresh!
  end

  def refresh_cohorts
    self.cohort.refresh!
  end

  protected 

  def generate_api_token 
    self.api_token = loop do
      random_token = SecureRandom.urlsafe_base64
      break random_token unless User.where(api_token: random_token).exists?
    end
  end

  def schedule_imports
    begin
      self.charge_imports.create(start_at:Time.now,end_at:BEGINING_OF_TIME,token:self.token,limit:MAX_IMPORTS)        
      self.customer_imports.create(start_at:Time.now,end_at:BEGINING_OF_TIME,token:self.token,limit:MAX_IMPORTS)
      self.cde_imports.create(start_at:Time.now,end_at:BEGINING_OF_TIME,token:self.token,limit:MAX_IMPORTS)        
      self.sde_imports.create(start_at:Time.now,end_at:BEGINING_OF_TIME,token:self.token,limit:MAX_IMPORTS)              
    rescue Exception => e
      logger.error "YYY: failed to schedule imports for users #{self._id}"
    end
  end

end
