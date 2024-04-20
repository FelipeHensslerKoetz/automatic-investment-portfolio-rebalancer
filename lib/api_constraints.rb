# frozen_string_literal: true
class ApiConstraints
  attr_reader :version, :default

  def initialize(options)
    @version = options[:version]
    @default = options[:default]
  end

  def matches?(req)
    return true if default && !req.headers['Accept'].include?('application/vnd.investment_portfolio_rebalancer.v')

    req.headers['Accept'].include?("application/vnd.investment_portfolio_rebalancer.v#{version}")
  end
end
