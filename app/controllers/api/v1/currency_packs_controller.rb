class Api::V1::CurrencyPacksController < Api::V1::BaseController
  def index
    @packs = CurrencyPack.includes(:currency)
    render json: @packs
  end

  def show
    @pack = CurrencyPack.find(params[:id])
    render json: @pack
  end
end
