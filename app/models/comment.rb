class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post
  has_many :comment_reactions, dependent: :destroy

  validates :body, presence: true
end 