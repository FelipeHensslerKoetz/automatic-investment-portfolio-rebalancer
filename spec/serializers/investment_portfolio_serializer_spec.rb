# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InvestmentPortfolioSerializer, type: :serializer do
  describe 'attributes' do
    it 'returns the correct attributes' do
      investment_portfolio = build(:investment_portfolio)
      serializer = described_class.new(investment_portfolio)

      expect(serializer.attributes).to eq(
        id: investment_portfolio.id,
        name: investment_portfolio.name,
        description: investment_portfolio.description
      )
    end
  end

  describe 'associations' do
    it 'returns the correct associations' do
      investment_portfolio = build(:investment_portfolio)
      serializer = described_class.new(investment_portfolio).as_json

      expect(serializer[:investment_portfolio_assets]).to eq(investment_portfolio.investment_portfolio_assets.map do |investment_portfolio_asset|
        InvestmentPortfolioAssetSerializer.new(investment_portfolio_asset).as_json
      end)

      expect(serializer[:currency]).to eq(CurrencySerializer.new(investment_portfolio.currency).as_json)
    end
  end
end
