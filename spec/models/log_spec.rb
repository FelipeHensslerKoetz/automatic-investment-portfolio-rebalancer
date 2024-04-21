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
end
