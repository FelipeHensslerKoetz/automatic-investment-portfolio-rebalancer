class RebalanceOrder < ApplicationRecord
  belongs_to :user
  belongs_to :investment_portfolio
end
