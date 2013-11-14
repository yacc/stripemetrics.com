class User
  include Mongoid::Document
  include Mongoid::Timestamps::Created::Short
  include Billable

  MAX_IMPORTS      = 50
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

  has_many :trends 

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


  def add_trends
    # Overview
    trends << Trend.new(type:"mrr",group:"overview",name:"Total MRR",
                             desc:"Monthly recuring revenue",
                             unit:"amount",source:"charges",interval:'month',
                             p_criteria:{"amount"=>"$amount"}, 
                             m_criteria:{"created"=>{"$ne"=>nil},"paid"=>true},
                             groupby_ts:%Q|created|)

    # MRR
    trends << Trend.new(type:"new_mrr",group:"mrr",name:"New MRR",
                             desc:"Monthly recuring revenue from new customers",
                             unit:"amount",source:"charges",interval:'month',
                             p_criteria:{"amount"=>"$amount"}, 
                             m_criteria:{"created"=>{"$ne"=>nil},"paid"=>true,"new_mrr"=>true},
                             groupby_ts:%Q|created|)

    trends << Trend.new(type:"failed_mrr",group:"lost",name:"Failed Charges",
                             desc:"Failing monthly recuring revenue from new customers",
                             unit:"amount",source:"charges",interval:'month',
                             p_criteria:{"amount"=>"$amount"}, 
                             m_criteria:{"paid"=>false},
                             groupby_ts:%Q|created|)

    trends << Trend.new(type:"failed_mrr_by_country",group:"mrr",name:"Failed MRR by countries",
                             desc:"Failing monthly recuring revenue from new customers",
                             unit:"amount",source:"charges",interval:'month',
                             p_criteria:{"amount"=>"$amount","country"=>"$card.country"}, 
                             m_criteria:{"paid"=>false},
                             groupby_ts:%Q|created|,dimension:'country')

    trends << Trend.new(type:"failed_mrr_by_cc_type",group:"mrr",name:"Failed MRR by card type",
                             desc:"Failing monthly recuring revenue from new customers",
                             unit:"amount",source:"charges",interval:'month',
                             p_criteria:{"amount"=>"$amount","card_type"=>"$card.card_type"}, 
                             m_criteria:{"paid"=>false},
                             groupby_ts:%Q|created|,dimension:'card_type')

    trends << Trend.new(type:"churn_mrr",group:"mrr",name:"Churn MRR",
                             desc:"The lost monthly recuring revenue from churning customers in the current month", 
                             unit:"amount",source:"customers",interval:'month',
                             p_criteria:{"amount"=>"$subscription.plan.amount"},
                             m_criteria:{"canceled_at"=>{"$ne"=>nil}},
                             groupby_ts:%Q|canceled_at|) 

    # CHURN METRICS
    trends << Trend.new(type:"new_cust",group:"churn",name:"# of new Customers",
                             desc:"# new of customers in the current month}", 
                             unit:"count",source:"customers",interval:'month',
                             p_criteria:{"customers" => 1}, 
                             m_criteria:{},
                             groupby_ts:%Q|created|)

    trends << Trend.new(type:"churn_cust",group:"churn",name:"# of churned  Customers",
                             desc:"# of churned customers in the current month}", 
                             unit:"count",source:"customers",interval:'month',
                             p_criteria:{"customers" => 1}, 
                             m_criteria:{"canceled_at"=>{"$ne"=>nil}},
                             groupby_ts:%Q|canceled_at|)
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
    add_trends if self.trends.empty?

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

  def refresh_metrics20
    (self.churn_mrr_metric.nil? ? self.churn_mrr_metric : self.churn_mrr_metric).refresh!
    (self.new_mrr_metric.nil? ? self.create_new_mrr_metric : self.new_mrr_metric).refresh!
  end

  def refresh_cohorts
    self.cohort.refresh!
  end

  def schedule_imports
    begin
      self.charge_imports.create(start_at:Time.now,end_at:BEGINING_OF_TIME,token:self.token,limit:MAX_IMPORTS)        
      self.customer_imports.create(start_at:Time.now,end_at:BEGINING_OF_TIME,token:self.token,limit:MAX_IMPORTS)
      self.cde_imports.create(start_at:Time.now,end_at:BEGINING_OF_TIME,token:self.token,limit:MAX_IMPORTS)        
      self.sde_imports.create(start_at:Time.now,end_at:BEGINING_OF_TIME,token:self.token,limit:MAX_IMPORTS)              
    rescue Exception => e
      logger.error "YYY: failed to schedule imports for users #{self._id}\n#{e.message}"
    end
  end


  protected 

  def generate_api_token 
    self.api_token = loop do
      random_token = SecureRandom.urlsafe_base64
      break random_token unless User.where(api_token: random_token).exists?
    end
  end


end
