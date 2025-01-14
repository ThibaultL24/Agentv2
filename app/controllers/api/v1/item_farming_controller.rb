class Api::V1::ItemFarmingController < ApplicationController
  def index
    @item_farmings = ItemFarming.includes(:item)
    render json: @item_farmings
  end

  def show
    @item_farming = ItemFarming.find(params[:id])
    render json: {
      farming_data: @item_farming,
      metrics: calculate_farming_metrics
    }
  end

  private

  def calculate_farming_metrics
    {
      daily_profit: @item_farming.efficiency * @item_farming.ratio,
      time_efficiency: @item_farming.ratio / @item_farming.inGameTime,
      estimated_daily_runs: 24 * 60 / @item_farming.inGameTime
    }
  end
end
