Warden::Manager.serialize_into_session { |user| user.uid }
Warden::Manager.serialize_from_session { |uid| User.find_by(uid:uid) }

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
    u = User.where(api_token:token_value).first
    u.nil? ? fail!("Could not log in") : success!(u)
  end

  private

  def token_value
    if header && header =~ /^Token=(.+)$/
      $~[1]
    else
      params && params['api_token']
    end
  end

  def header
    request.env["HTTP_AUTHORIZATION"]
  end

end

