class Api::V1::UserRechargesController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :authenticate_user!
  before_action :set_recharge, only: [:show, :update]

  def index
    @recharges = current_user.user_recharges
    render json: @recharges.map { |recharge|
      {
        id: recharge.id,
        discountTime: recharge.discountTime,
        discountNumber: recharge.discountNumber
      }
    }
  end

  def show
    render json: {
      recharge: {
        id: @recharge.id,
        discountTime: @recharge.discountTime,
        discountNumber: @recharge.discountNumber
      }
    }
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Recharge discount not found or not accessible" }, status: :not_found
  end

  def update
    if @recharge.update(recharge_params)
      render json: {
        recharge: {
          id: @recharge.id,
          discountTime: @recharge.discountTime,
          discountNumber: @recharge.discountNumber
        }
      }
    else
      render json: { error: @recharge.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Recharge discount not found or not accessible" }, status: :not_found
  end

  private

  def set_recharge
    @recharge = current_user.user_recharges.find(params[:id])
  end

  def recharge_params
    params.require(:user_recharge).permit(:discountNumber)
  end
end
