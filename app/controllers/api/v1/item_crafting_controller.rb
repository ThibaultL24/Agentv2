class Api::V1::ItemCraftingController < ApplicationController
  def index
    @item_craftings = ItemCrafting.includes(:item)
    render json: @item_craftings
  end

  def show
    @item_crafting = ItemCrafting.find(params[:id])
    render json: {
      crafting_data: @item_crafting,
      metrics: calculate_crafting_metrics
    }
  end

  private

  def calculate_crafting_metrics
    {
      crafting_cost: @item_crafting.nbLowerBadgeToCraft * base_badge_cost,
      units_per_craft: @item_crafting.unitToCraft,
      efficiency_ratio: @item_crafting.unitToCraft / @item_crafting.nbLowerBadgeToCraft
    }
  end
end
