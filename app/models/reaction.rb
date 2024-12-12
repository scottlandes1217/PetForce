class Reaction < ApplicationRecord
  belongs_to :user
  belongs_to :post

  # Ensure `reaction_type` is valid
  validates :reaction_type, presence: true, inclusion: {
    in: %w[like thumbs_up love haha wow sad angry 😂 ♥️ 👍],
    message: "%{value} is not a valid reaction"
  }
end