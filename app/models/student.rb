class Student < ApplicationRecord
  belongs_to :user
  validates :name, presence: true, length: { in: 3..30 }
  validates :subject, presence: true, length: { in: 3..20 }
  validates :marks, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
end
