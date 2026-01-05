module JwtService
  JWT_ISSUER = ENV.fetch("JWT_ISSUER")
  JWT_AUDIENCE = ENV.fetch("JWT_AUDIENCE")
  JWT_SECRET = ENV.fetch("JWT_SECRET")

  def encode_token(payload = {})
    payload[:iss] = JWT_ISSUER
    payload[:aud] = JWT_AUDIENCE
    JWT.encode(payload, JWT_SECRET, "HS256")
  end

  def decode_token(request)
    auth_header = request.headers["Authorization"]
    token = auth_header&.split&.last
    raise UnauthorizedError.new("No Token") unless token
    begin
      get_current_user(JWT.decode(token, JWT_SECRET, true, algorithm: "HS256"))
    rescue JWT::DecodeError
      raise UnauthenticatedError
    end
  end

  private
  def get_current_user(decoded_token)
    user_id = decoded_token[0]["user_id"]
    current_user = User.find_by(id: user_id)
    current_user ? current_user : raise(UnauthenticatedError)
  end
end
