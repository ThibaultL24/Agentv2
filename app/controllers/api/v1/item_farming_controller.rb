class Api::V1::ItemFarmingController < ApplicationController
  def index
    @item_farmings = ItemFarming.includes(:item)
    render json: @item_farmings
  end

  def show
    @item_farming = ItemFarming.find(params[:id])
    calculator = MetricsCalculator.new(@item_farming.item)
    metrics = calculator.calculate_badge_metrics

    render json: {
      farming_data: @item_farming,
      metrics: {
        daily_profit: metrics[:bft_per_day],
        matches_per_day: metrics[:matches_per_day],
        efficiency: metrics[:efficiency]
      }
    }
  end
end
