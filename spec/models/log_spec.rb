# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Log, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:kind) }
    it { is_expected.to validate_presence_of(:data) }

    it 'validates inclusion of type' do
      is_expected.to validate_inclusion_of(:kind).in_array(Log::LOG_KINDS.map(&:to_s))
    end
  end

  describe 'scopes' do
    let!(:error_log) { create(:log, :error) }
    let!(:info_log) { create(:log, :info) }

    describe '.error' do
      it 'returns logs with kind error' do
        expect(described_class.error).to eq([error_log])
      end
    end

    describe '.info' do
      it 'returns logs with kind info' do
        expect(described_class.info).to eq([info_log])
      end
    end
  end
end
