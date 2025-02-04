class Api::V1::ItemsController < ApplicationController
  def index
    @items = Item.includes(:type, :rarity, :item_farming, :item_crafting, :item_recharge)
    render json: @items
  end

  def show
    @item = Item.find(params[:id])
    calculator = MetricsCalculator.new(@item)

    render json: {
      item: @item,
      market_data: calculate_market_metrics,
      metrics: @item.type.name == 'Badge' ? calculator.calculate_badge_metrics : calculator.calculate_contract_metrics
    }
  end

  def create
    @item = Item.new(item_params)
    if @item.save
      render json: @item, status: :created
    else
      render json: @item.errors, status: :unprocessable_entity
    end
  end

  def update
    @item = Item.find(params[:id])
    if @item.update(item_params)
      render json: @item
    else
      render json: @item.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @item = Item.find(params[:id])
    @item.destroy
    head :no_content
  end

  private

  def calculate_market_metrics
    {
      supply: {
        total: @item.supply,
        circulating: @item.nfts.count,
        available: @item.supply - @item.nfts.count
      },
      price: {
        floor: @item.floorPrice
      }
    }
  end

  def item_params
    params.require(:item).permit(
      :rarity, :type, :name, :efficiency,
      :nfts, :supply, :floorPrice,
      :type_id, :rarity_id
    )
  end
end
