class User
  include Mongoid::Document

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

  validates_uniqueness_of :email, :message => "already in use"

  has_many :customers, dependent: :delete
  has_many :charges, dependent: :delete
  has_many :charge_imports, dependent: :delete
  has_many :customer_imports, dependent: :delete
  has_many :sde_imports, dependent: :delete
  has_many :cde_imports, dependent: :delete

  has_one  :acquisition_trend, dependent: :delete, autobuild: true
  has_one  :cancellation_trend, dependent: :delete, autobuild: true
  has_one  :paid_charge_count_trend , dependent: :delete, autobuild: true
  has_one  :failed_charge_count_trend, dependent: :delete, autobuild: true
  has_one  :paid_charge_volume_trend , dependent: :delete, autobuild: true
  has_one  :failed_charge_volume_trend, dependent: :delete, autobuild: true

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

  def is_premium?
    false  
  end

  def refresh_data
    # get the timestamp of the last imported object
    last_charge_import = self.charge_imports.order_by(:last_imported_ts.asc).last.last_imported_ts
    last_customer_import = self.customer_imports.order_by(:last_imported_ts.asc).last.last_imported_ts
    last_cde_import = self.cde_imports.order_by(:last_imported_ts.asc).last.last_imported_ts
    last_sde_import = self.sde_imports.order_by(:last_imported_ts.asc).last.last_imported_ts
    # schedule the imports    
    self.charge_imports.create(start_at:Time.now,end_at:last_charge_import,token:self.token,limit:MAX_IMPORTS)        
    self.customer_imports.create(start_at:Time.now,end_at:last_customer_import,token:self.token,limit:MAX_IMPORTS)
    self.cde_imports.create(start_at:Time.now,end_at:last_cde_import,token:self.token,limit:MAX_IMPORTS)        
    self.sde_imports.create(start_at:Time.now,end_at:last_sde_import,token:self.token,limit:MAX_IMPORTS)        
  end

  protected 

  def generate_api_token 
    self.api_token = loop do
      random_token = SecureRandom.urlsafe_base64
      break random_token unless User.where(api_token: random_token).exists?
    end
  end

  def schedule_imports
    self.charge_imports.create(start_at:Time.now,end_at:BEGINING_OF_TIME,token:self.token,limit:MAX_IMPORTS)        
    self.customer_imports.create(start_at:Time.now,end_at:BEGINING_OF_TIME,token:self.token,limit:MAX_IMPORTS)
    self.cde_imports.create(start_at:Time.now,end_at:BEGINING_OF_TIME,token:self.token,limit:MAX_IMPORTS)        
    self.sde_imports.create(start_at:Time.now,end_at:BEGINING_OF_TIME,token:self.token,limit:MAX_IMPORTS)        
  end

end
