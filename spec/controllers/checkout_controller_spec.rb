require 'rails_helper'

RSpec.describe CheckoutController, type: :controller do
  let(:user) { create(:user) }
  let(:payment_method) { create(:payment_method, provider: 'stripe') }

  before do
    sign_in user
  end

  describe 'POST #create' do
    let(:valid_params) { { amount: 10.0, currency_type: 'FLEX' } }

    it 'creates a Stripe session' do
      post :create, params: valid_params
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to include('sessionId', 'sessionUrl')
    end
  end
end
