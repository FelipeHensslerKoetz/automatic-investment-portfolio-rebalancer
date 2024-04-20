require 'rails_helper'

RSpec.describe PartnerResource, type: :model do
  describe 'constants' do
    it { expect(described_class::INTEGRATED_PARTNER_RESOURCES).to include(:hg_brasil) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:partner) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:slug) }

    it 'validates inclusion of slug' do
      partner_resource = build(:partner_resource, slug: 'invalid')
      partner_resource.valid?

      expect(partner_resource).to be_invalid
      expect(partner_resource.errors[:slug]).to include('is not included in the list')
    end
  end
end
