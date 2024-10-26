class InvestmentPortfolioRebalanceNotificationOption < ApplicationRecord
  NOTIFICATION_OPTION_KINDS = %w[webhook email].freeze

  belongs_to :investment_portfolio
  has_many :investment_portfolio_rebalance_notification_orders, dependent: :restrict_with_error

  validates :name, :kind, presence: true
  validates :kind, inclusion: { in: NOTIFICATION_OPTION_KINDS }
  validates :url, presence: true, if: -> { webhook? }
  validate :valid_header, if: -> { header.present? }
  before_validation :set_default_header

  def webhook?
    kind == 'webhook'
  end

  def email?
    kind == 'email'
  end

  private

  def set_default_header
    self.header = {} if header.blank?
  end

  def valid_header
    return if header.is_a?(Hash)

    errors.add(:header, 'must be an object')
  end
end
