# app/controllers/api/v1/data_lab_controller.rb
class Api::V1::DataLabController < ApplicationController
  before_action :authenticate_user!

  def slots_metrics
    response = Rails.cache.fetch("data_lab/slots/#{current_user.id}", expires_in: 1.hour) do
      DataLab::SlotsMetricsCalculator.new(current_user).calculate
    end

    render json: response
  end
end
