require 'rails_helper'

RSpec.describe Transaction, type: :model do
  # Créons d'abord les objets nécessaires pour les tests
  let(:user) { create(:user) }
  let(:payment_method) { create(:payment_method) }

  # Créons un sujet valide pour les tests
  subject {
    described_class.new(
      user: user,
      payment_method: payment_method,
      amount: 10.0,
      currency: 'EUR',
      status: 'pending',
      external_id: 'tx_123'
    )
  }

  describe 'validations' do
    it { should validate_presence_of(:amount) }
    it { should validate_presence_of(:currency) }
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:external_id) }

    # Pour le test d'unicité, on spécifie le sujet avec les associations requises
    it { should validate_uniqueness_of(:external_id).scoped_to([]) }

    it { should validate_numericality_of(:amount).is_greater_than(0) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:payment_method) }
  end
end
