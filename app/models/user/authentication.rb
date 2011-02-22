class User
  
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  before_save :ensure_authentication_token
  after_save :write_auth_token_to_store
  
  def self.authenticate(login, password)
    unless login.blank? or password.blank?
      u = find_by_username_or_email(login)
      u && u.authenticated?(password) ? u : nil
    end
  end

  #user to authenticate users via redis
  def ensure_authentication_token
    self.authentication_token ||= ActiveSupport::SecureRandom.hex(20)
    @write_auth_token = self.authentication_token_changed?
    true
  end

  def write_auth_token_to_store
    if $redis && @write_auth_token
      $redis.set("teambox/users/#{self.authentication_token}", self.login) 
      @write_auth_token = false
    end
    true
  end

end
