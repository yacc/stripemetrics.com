class User
  include Mongoid::Document
  rolify
  field :provider, type: String
  field :uid,      type: String
  field :name,     type: String
  field :email,    type: String
  field :livemode, type: Boolean
  field :token,    type: String
  field :token_expires, type: Boolean

  has_many :customers
  has_one  :acquisition_trend

  attr_accessible :role_ids, :as => :admin
  attr_accessible :provider, :uid, :name, :email

  index({ email: 1 }, { unique: true, background: true })

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

end
