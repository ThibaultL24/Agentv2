class Api::V1::CurrencyPacksController < ApplicationController
  def index
    @currency_packs = CurrencyPack.all
    render json: @currency_packs
  end

  def show
    @currency_pack = CurrencyPack.find(params[:id])
    render json: {
      currency_pack: @currency_pack,
      currency: @currency_pack.currency
    }
  end
end
