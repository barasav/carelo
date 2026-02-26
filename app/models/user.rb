class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :plants, dependent: :destroy
  has_many :animals, dependent: :destroy
  has_many :consumable_items, dependent: :destroy
  has_many :stock_lots, dependent: :destroy
end
