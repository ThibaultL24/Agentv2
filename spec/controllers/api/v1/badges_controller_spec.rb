require 'rails_helper'

RSpec.describe Api::V1::BadgesController, type: :controller do
  let(:user) { create(:user) }
  let(:item) { create(:item, :with_farming, :with_crafting, :with_recharge) }
  let(:badge) { create(:badge, owner: user.openLootID, itemId: item.id) }

  before do
    # Simulons l'authentification pour les tests de contrôleur
    allow(controller).to receive(:authenticate_user!).and_return(true)
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

    context 'when viewing an item badge' do
      it 'returns badge with correct metrics' do
        get :show, params: { id: item.id, type: 'item' }

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)

        expect(json).to include('badge', 'roi_analysis', 'metrics')
        expect(json['metrics']).to include(
          'efficiency',
          'ratio',
          'charges',
          'matches_per_charge',
          'matches_per_day',
          'bft_per_minute',
          'bft_per_charge',
          'bft_per_day'
        )

        # Vérification des valeurs spécifiques pour Epic
        expect(json['metrics']['efficiency']).to eq(12.92)
        expect(json['metrics']['bft_per_day']).to eq(15504)
      end
    end

    context 'when viewing an owned badge' do
      it 'returns badge with ROI analysis' do
        get :show, params: { id: badge.id }

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)

        expect(json['roi_analysis']).to include(
          'matches_to_roi',
          'daily_matches_possible',
          'estimated_days_to_roi'
        )

        expect(json['roi_analysis']['daily_matches_possible']).to eq(24)
      end
    end
  end

  describe 'GET #index' do
    it 'returns all user badges' do
      get :index
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)).to be_an(Array)
    end

    context 'when listing available badges' do
      before do
        create_list(:item, 3, :badge, rarity_name: 'Epic')
      end

      it 'returns all available badges with basic metrics' do
        get :index, params: { status: 'available' }

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)

        expect(json.size).to eq(3)
        expect(json.first['badge']).to include(
          'efficiency',
          'supply',
          'floorPrice'
        )
      end
    end

    context 'when listing owned badges' do
      before do
        create_list(:badge, 3, item: item, owner: user.openLootID)
      end

      it 'returns owned badges with purchase info' do
        get :index

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)

        expect(json.size).to eq(3)
        expect(json.first['badge']).to include(
          'purchasePrice',
          'issueId'
        )
      end
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
