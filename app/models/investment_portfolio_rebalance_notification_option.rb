class InvestmentPortfolioRebalanceNotificationOption < ApplicationRecord
  NOTIFICATION_OPTION_KINDS = %w[webhook email].freeze
  HTTP_METHODS = %w[get post put patch delete].freeze

  belongs_to :investment_portfolio

  validates :name, :kind, presence: true
  validates :kind, inclusion: { in: NOTIFICATION_OPTION_KINDS }
  validates :http_method, inclusion: { in: HTTP_METHODS }, if: -> { webhook? }
  validates :http_method, :url, presence: true, if: -> { webhook? }
  validate :valid_header, if: -> { header.present? }
  validate :valid_body, if: -> { body.present? }
  before_validation :set_default_header
  before_validation :set_default_body

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

  def set_default_body
    self.body = {} if body.blank?
  end

  def valid_header
    return if header.is_a?(Hash)

    errors.add(:header, 'must be an object')
  end

  def valid_body
    return if body.is_a?(Hash) || body.is_a?(Array)

    errors.add(:body, 'must be an object or an array')
  end
end
