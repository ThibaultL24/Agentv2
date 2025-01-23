class Api::V1::BaseController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  private

  def not_found
    render json: {
      status: 404,
      error: :not_found
    }, status: :not_found
  end
end
