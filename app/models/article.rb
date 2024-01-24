class Article < ApplicationRecord
  include Visible

  belongs_to :category
  has_many :comments, dependent: :destroy
  has_one_attached :image, dependent: :destroy

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
end