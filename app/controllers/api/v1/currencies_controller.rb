class Api::V1::CurrenciesController < Api::V1::BaseController
  def index
    @currencies = Currency.includes(:game)
    render json: @currencies
  end

  def show
    @currency = Currency.find(params[:id])
    render json: {
      currency: @currency,
      packs: @currency.currency_packs
    }
  end
end
