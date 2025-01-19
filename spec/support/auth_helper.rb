module AuthHelper
  def sign_in(user)
    token = user.generate_jwt
    request.headers['Authorization'] = "Bearer #{token}"
  end

  def auth_headers(user)
    token = user.generate_jwt
    { 'Authorization': "Bearer #{token}" }
  end

  # Helper spécifique pour les tests de contrôleur
  def mock_auth_for_controller(controller, user)
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
  end
end

RSpec.configure do |config|
  config.include AuthHelper, type: :controller
  config.include AuthHelper, type: :request
end
