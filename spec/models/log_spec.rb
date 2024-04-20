require 'rails_helper'

RSpec.describe Log, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:type) }
    it { is_expected.to validate_presence_of(:data) }

    it 'validates inclusion of type' do
      is_expected.to validate_inclusion_of(:type).in_array(Log::LOG_TYPES.map(&:to_s))
    end
  end
end
