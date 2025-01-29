class Api::V1::ItemFarmingController < ApplicationController
  def index
    @item_farmings = ItemFarming.includes(:item)
    render json: @item_farmings
  end

  def show
    @item_farming = ItemFarming.find(params[:id])
    calculator = MetricsCalculator.new(@item_farming.item)

    render json: {
      farming_data: @item_farming,
      metrics: {
        daily_profit: calculator.calculate_sbft_per_minute * 1440, # 24h * 60min
        time_efficiency: @item_farming.ratio / @item_farming.in_game_time,
        estimated_daily_runs: calculator.calculate_daily_matches_possible
      }
    }
  end
end
