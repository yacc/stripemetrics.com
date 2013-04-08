class User
  include Mongoid::Document
  
  field :provider, type: String
  field :uid,      type: String
  field :email,    type: String
  field :encrypted_password, :type => String
  field :livemode, type: Boolean
  field :api_token,    type: String
  field :token,    type: String
  field :token_expires, type: Boolean

  attr_accessor :password
  validates_presence_of   :password, :on => :create, :message => "can't be blank"
  validates_presence_of   :email, :message => "can't be blank"
  validates_uniqueness_of :email, :message => "already in use"


  has_many :customers
  has_many :charges
  has_many :import_directors

  has_one  :acquisition_trend
  has_one  :cancellation_trend
  has_one  :paid_charge_count_trend 
  has_one  :failed_charge_count_trend
  has_one  :paid_charge_volume_trend 
  has_one  :failed_charge_volume_trend
  embeds_one   :account

  attr_accessible :provider, :uid, :name, :email

  index({ email: 1 }, { unique: true, background: true })
  index({ api_token: 1 }, { unique: true, background: true })

  after_create :add_import_directors
  before_create :generate_api_token, :encrypt_password


  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth['provider']
      user.uid = auth['uid']
      if auth['info']
         user.livemode = auth['info']['livemode'] || false
      end
      if auth['credentials']
        user.token = auth['credentials']['token'] || ''
        user.token_expires = auth['credentials']['expires'] || true
      end
    end
  end

  def self.authenticate email, password
    user = where(:email => email).first
    if user && user.saved_password == password
      user
    else
      nil
    end
  end

  protected 

  def add_import_directors
    self.import_directors << CDEImportDirector.create
    self.import_directors << SDEImportDirector.create  
    self.import_directors << ChargeImportDirector.create  
    self.import_directors << CustomerImportDirector.create  
  end

  def generate_token #shouldn't the api token be encrypted as well ?
    self.token = loop do
      random_token = SecureRandom.urlsafe_base64
      break random_token unless User.where(api_token: random_token).exists?
    end
  end

  def saved_password
    @saved_password ||= BCrypt::Password.new(encrypted_password)
  end

  def saved_password=(new_password)
    @saved_password = BCrypt::Password.create(new_password)
    self.encrypted_password = @saved_password
  end

  def encrypt_password
    saved_password = password if password.present?
  end

end
