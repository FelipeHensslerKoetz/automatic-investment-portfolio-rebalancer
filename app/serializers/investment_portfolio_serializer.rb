# frozen_string_literal: true

class InvestmentPortfolioSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :total_value

  has_many :investment_portfolio_assets

  def total_value
    object.investment_portfolio_assets.sum  do |investment_portfolio_asset|
      asset = investment_portfolio_asset.asset
      partner_resource = PartnerResource.find_by(slug: 'br_api_assets') || PartnerResource.find_by(slug: 'hg_brasil_assets')
      partner_resource = nil if  investment_portfolio_asset.asset.custom
      investment_portfolio_asset.quantity * asset.asset_prices.find_by(partner_resource: partner_resource).price
    end
  end
end
