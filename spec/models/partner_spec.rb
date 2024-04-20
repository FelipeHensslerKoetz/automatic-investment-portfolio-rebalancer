require 'rails_helper'

RSpec.describe Partner, type: :model do
  describe 'constants' do
    it { expect(described_class::INTEGRATED_PARTNERS).to eq([:hg_brasil]) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:partner_resources).dependent(:restrict_with_error) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:slug) }

    it 'validates uniqueness of name' do
      create(:partner, :hg_brasil, name: 'HG Brasil')
      partner = build(:partner, :hg_brasil, name: 'HG Brasil')
      partner.valid?

      expect(partner).to be_invalid
      expect(partner.errors[:name]).to include('has already been taken')
    end
  end
end
