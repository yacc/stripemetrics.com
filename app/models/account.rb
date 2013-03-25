class Account
  include Mongoid::Document

  field :name, type: String
  field :name, type: String

  embedded_in :user
end
