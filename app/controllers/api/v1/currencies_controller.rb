class Api::V1::CurrenciesController < ApplicationController
  def index
    @currencies = Currency.all
    render json: @currencies
  end

  def show
    @currency = Currency.find(params[:id])
    render json: {
      currency: @currency,
      currency_packs: @currency.currency_packs
    }
  end
end
