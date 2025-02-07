class Api::V1::ItemFarmingController < Api::V1::BaseController
  before_action :authenticate_user!

  def index
    @item_farmings = ItemFarming.includes(item: [:type, :rarity])
                               .where(items: { types: { name: ['Badge', 'Contract'] }})

    render json: {
      farmings: @item_farmings.map { |farming| farming_json(farming) }
    }
  end

  def show
    @item_farming = ItemFarming.includes(item: [:type, :rarity]).find(params[:id])
    calculator = MetricsCalculator.new(@item_farming.item)
    metrics = calculator.calculate_badge_metrics

    render json: {
      farming: farming_json(@item_farming),
      metrics: farming_metrics(metrics)
    }
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Farming data not found" }, status: :not_found
  end

  private

  def farming_json(farming)
    {
      id: farming.id,
      item: {
        id: farming.item.id,
        name: farming.item.name,
        type: farming.item.type.name,
        rarity: farming.item.rarity.name
      },
      efficiency: farming.efficiency,
      ratio: farming.ratio,
      in_game_time: farming.in_game_time
    }
  end

  def farming_metrics(metrics)
    {
      daily_profit: metrics[:bft_per_day],
      matches_per_day: metrics[:matches_per_day],
      efficiency: metrics[:efficiency],
      estimated_roi_days: metrics[:roi_days]
    }
  end
end
