# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CustomerSupportItem, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:status) }
  end

  describe 'aasm' do
    it { is_expected.to have_state(:opened) }
    it { is_expected.to transition_from(:opened).to(:in_progress).on_event(:progress) }
    it { is_expected.to transition_from(:in_progress).to(:closed).on_event(:close) }
  end
end
