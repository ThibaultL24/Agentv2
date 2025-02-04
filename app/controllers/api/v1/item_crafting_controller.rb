class Api::V1::ItemCraftingController < ApplicationController
  def index
    @item_craftings = ItemCrafting.includes(:item)
    render json: @item_craftings
  end

  def show
    @item_crafting = ItemCrafting.find(params[:id])
    calculator = MetricsCalculator.new(@item_crafting.item)
    metrics = calculator.calculate_badge_metrics

    render json: {
      crafting_data: @item_crafting,
      metrics: {
        craft_time: metrics[:craft_time],
        flex_craft_cost: metrics[:flex_craft_cost],
        sponsor_marks_cost: metrics[:sponsor_marks_cost],
        total_craft_cost_usd: metrics[:total_craft_cost_usd]
      }
    }
  end

  private

  def calculate_crafting_metrics
    {
      crafting_cost: calculate_total_crafting_cost,
      units_per_craft: @item_crafting.unitToCraft,
      efficiency_ratio: @item_crafting.unitToCraft / @item_crafting.nbLowerBadgeToCraft
    }
  end

  def calculate_total_crafting_cost
    base_cost = @item_crafting.nbLowerBadgeToCraft * @item_crafting.item.base_badge_cost
    base_cost + @item_crafting.additional_costs
  end
end
