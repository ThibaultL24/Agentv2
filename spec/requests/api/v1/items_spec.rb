require 'rails_helper'

RSpec.describe 'Items API', type: :request do
  let(:user) { create(:user) }
  let(:token) { user.generate_jwt }
  let(:headers) { { 'Authorization': "Bearer #{token}" } }

  describe 'GET /api/v1/items' do
    before do
      create_list(:item, 3, :with_farming, :with_crafting, :with_recharge)
    end

    it 'returns all items' do
      get '/api/v1/items', headers: headers

      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).size).to eq(3)
    end
  end

  describe 'GET /api/v1/items/:id' do
    let(:item) { create(:item, :with_farming, :with_crafting, :with_recharge) }

    it 'returns item with market data' do
      get "/api/v1/items/#{item.id}", headers: headers

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json).to include('market_data')
      expect(json['market_data']).to include('supply', 'price')
    end
  end
end
