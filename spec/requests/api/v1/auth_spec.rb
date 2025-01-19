require 'rails_helper'

RSpec.describe 'Authentication', type: :request do
  let(:user) { create(:user) }
  let(:valid_credentials) { { user: { email: user.email, password: 'password123' } } }
  let(:invalid_credentials) { { user: { email: user.email, password: 'wrong' } } }

  describe 'POST /api/v1/login' do
    context 'with valid credentials' do
      it 'returns authentication token' do
        post '/api/v1/login', params: valid_credentials
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)).to include('token')
      end
    end

    context 'with invalid credentials' do
      it 'returns error' do
        post '/api/v1/login', params: invalid_credentials
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'protected endpoints' do
    let(:token) { user.generate_jwt }
    let(:headers) { { 'Authorization': "Bearer #{token}" } }

    it 'denies access without token' do
      get '/api/v1/badges'
      expect(response).to have_http_status(:unauthorized)
    end

    it 'allows access with valid token' do
      get '/api/v1/badges', headers: headers
      expect(response).to have_http_status(:success)
    end
  end
end
