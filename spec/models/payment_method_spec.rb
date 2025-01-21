require 'rails_helper'

RSpec.describe PaymentMethod, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:provider) }
    it { should validate_uniqueness_of(:provider) }
  end

  describe 'associations' do
    it { should have_many(:transactions) }
  end

  describe 'scopes' do
    let!(:active_method) { PaymentMethod.create(name: 'Active', provider: 'stripe', is_active: true) }
    let!(:inactive_method) { PaymentMethod.create(name: 'Inactive', provider: 'old_stripe', is_active: false) }

    it 'returns only active payment methods' do
      expect(PaymentMethod.active).to include(active_method)
      expect(PaymentMethod.active).not_to include(inactive_method)
    end
  end
end
