class Api::V1::SessionsController < Devise::SessionsController
  skip_before_action :authenticate_user!, only: :create
  respond_to :json

  def create
    user = User.find_by(email: sign_in_params[:email])
    if user&.valid_password?(sign_in_params[:password])
      render json: {
        token: user.generate_jwt,
        user: user
      }, status: :ok
    else
      render json: { error: 'Invalid credentials' }, status: :unauthorized
    end
  end

  private

  def sign_in_params
    params.require(:user).permit(:email, :password)
  end

  def respond_with(resource, _opts = {})
    if resource
      render json: {
        token: resource.generate_jwt,
        user: resource
      }, status: :ok
    else
      render json: { error: 'Invalid credentials' }, status: :unauthorized
    end
  end

  def respond_to_on_destroy
    head :no_content
  end
end