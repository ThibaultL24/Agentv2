class Api::V1::BaseController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token

  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActionController::ParameterMissing, with: :bad_request

  private

  def not_found
    render json: {
      status: 404,
      error: :not_found,
      message: "Resource not found"
    }, status: :not_found
  end

  def bad_request(e)
    render json: {
      status: 400,
      error: :bad_request,
      message: e.message
    }, status: :bad_request
  end

  def authenticate_user!
    if request.headers['Authorization'].present?
      token = request.headers['Authorization'].split(' ').last
      begin
        jwt_payload = JWT.decode(token, Rails.application.credentials.devise_jwt_secret_key!).first
        @current_user_id = jwt_payload['id']
      rescue JWT::ExpiredSignature, JWT::VerificationError, JWT::DecodeError
        head :unauthorized
      end
    else
      head :unauthorized
    end
  end

  def current_user
    @current_user ||= User.find(@current_user_id)
  end
end
