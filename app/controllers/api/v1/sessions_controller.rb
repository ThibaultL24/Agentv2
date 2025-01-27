class Api::V1::SessionsController < Devise::SessionsController
  skip_before_action :authenticate_user!, only: :create
  respond_to :json
  skip_before_action :verify_authenticity_token

  def create
    user = User.find_by(email: sign_in_params[:email])
    if user&.valid_password?(sign_in_params[:password])
      token = JWT.encode(
        {
          'id' => user.id,
          'email' => user.email,
          'username' => user.username,
          'exp' => 24.hours.from_now.to_i
        },
        Rails.application.credentials.devise_jwt_secret_key!
      )

      render json: {
        user: user,
        token: token,
        message: 'Logged in successfully'
      }, status: :ok
    else
      render json: { error: 'Invalid credentials' }, status: :unauthorized
    end
  end

  def destroy
    # Simplement renvoyer un succès, le frontend supprimera le token
    render json: { message: 'Logged out successfully' }, status: :ok
  end

  private

  def sign_in_params
    params.require(:user).permit(:email, :password)
  end
end
