# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AssetOutdatedError do
  subject { described_class.new(asset:) }

  let(:asset) { create(:asset) }

  it 'inherits from StandardError' do
    expect(subject).to be_a(StandardError)
  end

  it 'has a message' do
    expect(subject.message).to eq("Asset with id: #{asset.id} is outdated.")
  end

  it 'has an asset attribute' do
    expect(subject.asset).to eq(asset)
  end
end
