module JwtHelper
  def mock_jwt_for_user(user)
    allow(user).to receive(:generate_jwt).and_return('fake-jwt-token')
  end
end

RSpec.configure do |config|
  config.include JwtHelper
end
