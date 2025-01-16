module AuthHelper
  def sign_in(user)
    # Simuler l'authentification selon votre système
    allow(controller).to receive(:current_user).and_return(user)
  end
end

RSpec.configure do |config|
  config.include AuthHelper, type: :controller
end
