class Api::V1::CurrenciesController < ApplicationController
  def index
    @currencies = Currency.all
    render json: @currencies
  end

  def show
    @currency = Currency.includes(:currency_packs).find(params[:id])
    render json: @currency.as_json(include: :currency_packs)
  end
end
