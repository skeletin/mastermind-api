class AuthService < ApplicationService
  def register(user_params)
    user = User.create!(user_params)
    encode_token(user_id: user.id)
  end

  def login(user_params)
    user = User.find_by(username: user_params[:username])
    raise InvalidCredentialsError unless user && user.authenticate(user_params[:password])
    encode_token(user_id: user.id)
  end

  def is_logged_in(request)
    decode_token(request)
  end
end
