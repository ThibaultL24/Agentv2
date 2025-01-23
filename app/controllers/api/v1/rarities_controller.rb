class Api::V1::RaritiesController < Api::V1::BaseController
  def index
    @rarities = Rarity.all
    render json: @rarities
  end

  def show
    @rarity = Rarity.find(params[:id])
    render json: @rarity
  end
end
