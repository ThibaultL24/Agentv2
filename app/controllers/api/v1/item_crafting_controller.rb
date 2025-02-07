class Api::V1::ItemCraftingController < Api::V1::BaseController
  before_action :authenticate_user!

  def index
    @item_craftings = ItemCrafting.includes(item: [:type, :rarity])
                                 .where(items: { types: { name: ['Badge', 'Contract'] }})

    render json: {
      craftings: @item_craftings.map { |crafting| crafting_json(crafting) }
    }
  end

  def show
    @item_crafting = ItemCrafting.includes(item: [:type, :rarity]).find(params[:id])
    calculator = MetricsCalculator.new(@item_crafting.item)
    metrics = calculator.calculate_badge_metrics

    render json: {
      crafting: crafting_json(@item_crafting),
      metrics: crafting_metrics(metrics)
    }
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Crafting data not found" }, status: :not_found
  end

  private

  def crafting_json(crafting)
    {
      id: crafting.id,
      item: {
        id: crafting.item.id,
        name: crafting.item.name,
        type: crafting.item.type.name,
        rarity: crafting.item.rarity.name
      },
      unit_to_craft: crafting.unit_to_craft,
      flex_craft: crafting.flex_craft,
      sponsor_mark_craft: crafting.sponsor_mark_craft,
      nb_lower_badge_to_craft: crafting.nb_lower_badge_to_craft
    }
  end

  def crafting_metrics(metrics)
    {
      craft_time: metrics[:craft_time],
      flex_craft_cost: metrics[:flex_craft_cost],
      sponsor_marks_cost: metrics[:sponsor_marks_cost],
      total_craft_cost_usd: metrics[:total_craft_cost_usd],
      estimated_roi_days: metrics[:roi_days]
    }
  end
end
