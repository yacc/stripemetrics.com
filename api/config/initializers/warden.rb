Warden::Manager.serialize_into_session { |user| user.uid }
Warden::Manager.serialize_from_session { |uid| User.get(uid) }

Warden::Strategies.add(:password) do

  def valid?
    params &&( params['username'] || params['password'])
  end

  def authenticate!
    u = User.authenticate(params['username'], params['password'])
    u.nil? ? fail!("Could not log in") : success!(u)
  end
end

Warden::Strategies.add(:api_token) do

  def valid?
    token_value.present?
  end

  def authenticate!
    u = User.where(api_token: params['api_token']).first
    u.nil? ? fail!("Could not log in") : success!(u)
  end

  private

  def token_value
    if header && header =~ /^Token token="(.+)"$/
      $~[1]
    else
      params && params['api_token']
    end
  end

  def header
    request.headers["Authorization"]
  end

end

