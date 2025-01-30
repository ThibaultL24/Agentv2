class Api::V1::UserRechargesController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :authenticate_user!
  before_action :set_recharge, only: [:show, :update]

  VALID_DISCOUNT_TIMES = [5, 9, 10, 13, 16, 20, 25].freeze

  def index
    @recharges = current_user.user_recharges
    render json: {
      recharges: @recharges.map { |recharge|
        {
          id: recharge.id,
          discountTime: recharge.discountTime,
          discountNumber: recharge.discountNumber,
          description: get_discount_description(recharge.discountTime)
        }
      },
      total_discounts: @recharges.sum(&:discountNumber)
    }
  end

  def show
    render json: {
      recharge: {
        id: @recharge.id,
        discountTime: @recharge.discountTime,
        discountNumber: @recharge.discountNumber,
        description: get_discount_description(@recharge.discountTime)
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
          discountNumber: @recharge.discountNumber,
          description: get_discount_description(@recharge.discountTime)
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

  def get_discount_description(discount_time)
    case discount_time
    when 25 then "Legendary Rowdy Fighter Discount"
    when 20 then "Gladiator Rowdy Fighter Discount"
    when 16 then "Fighter Rowdy Fighter Discount"
    when 13 then "Challenger Rowdy Fighter Discount"
    when 10 then "Debutant Rowdy Fighter Discount"
    when 9 then "Tournament Winner Discount"
    when 5 then "Alpha Fighter Discount"
    else "Standard Discount"
    end
  end
end
