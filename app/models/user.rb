# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are: :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable,
         :confirmable,
         :trackable

  include DeviseTokenAuth::Concerns::User

  # Associations
  has_many :assets, dependent: :restrict_with_error
  has_many :investment_portfolios, dependent: :restrict_with_error
  has_many :rebalance_orders, dependent: :restrict_with_error
  has_many :customer_support_items, dependent: :restrict_with_error
  has_many :customer_support_item_messages, dependent: :restrict_with_error
end
