class Api::V1::ItemsController < Api::V1::BaseController
  def index
    @items = Item.includes(:type, :rarity)

    # Permettre le filtrage par type (Badge ou Contract)
    @items = @items.where(type_id: Type.find_by(name: params[:type_name]).id) if params[:type_name].present?

    render json: @items.map { |item|
      item_json(item)
    }
  end

  def show
    @item = Item.includes(:type, :rarity).find(params[:id])

    render json: item_json(@item).merge(
      market_data: calculate_market_metrics
    )
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Item not found" }, status: :not_found
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

  def item_json(item)
    {
      id: item.id,
      name: item.name,
      type: item.type.as_json(only: [:id, :name]),
      rarity: item.rarity.as_json(only: [:id, :name, :color]),
      efficiency: item.efficiency,
      supply: item.supply,
      floorPrice: item.floorPrice,
      total_minted: item.nfts.count
    }
  end

  def calculate_market_metrics
    {
      supply: {
        total: @item.supply,
        minted: @item.nfts.count,
        available: @item.supply - @item.nfts.count
      },
      price: {
        floor: @item.floorPrice,
        last_sold: @item.nfts.order(created_at: :desc).first&.purchasePrice
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
