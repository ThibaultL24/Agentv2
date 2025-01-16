require 'rails_helper'

RSpec.describe Api::V1::BadgesController, type: :controller do
  let(:user) { create(:user) }
  let(:item) { create(:item, :with_farming, :with_crafting, :with_recharge) }
  let(:badge) { create(:badge, owner: user.openLootID, itemId: item.id) }

  before do
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe 'GET #show' do
    it 'returns badge with correct structure' do
      get :show, params: { id: badge.id }

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)

      expect(json).to include('badge', 'roi_analysis')
      expect(json['badge']).to include(
        'id',
        'issueId',
        'itemId',
        'owner'
      )
    end
  end

  describe 'GET #index' do
    it 'returns all user badges' do
      get :index
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)).to be_an(Array)
    end
  end

  describe 'ROI calculations' do
    it 'returns ROI metrics in show action' do
      get :show, params: { id: badge.id }

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json).to include('badge', 'roi_analysis')
      expect(json['roi_analysis']).to include(
        'matches_to_roi',
        'daily_matches_possible',
        'estimated_days_to_roi'
      )
    end

    it 'calculates positive number of matches for ROI' do
      get :show, params: { id: badge.id }

      json = JSON.parse(response.body)
      expect(json['roi_analysis']['matches_to_roi']).to be > 0
      expect(json['roi_analysis']['daily_matches_possible']).to eq(144) # 24h * 60min / 10min
      expect(json['roi_analysis']['estimated_days_to_roi']).to be > 0
    end
  end
end
