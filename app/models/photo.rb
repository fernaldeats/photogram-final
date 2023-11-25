# == Schema Information
#
# Table name: photos
#
#  id             :integer          not null, primary key
#  caption        :text
#  comments_count :integer
#  image          :string
#  likes_count    :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  owner_id       :integer
#
class Photo < ApplicationRecord

  validates :owner_id, presence: true
  validates :image, presence: true

  belongs_to :poster, required: true, class_name: "User", foreign_key: "owner_id", counter_cache: :own_photos_count
  has_many  :comments, class_name: "Comment", foreign_key: "photo_id", dependent: :destroy
  has_many  :likes, class_name: "Like", foreign_key: "photo_id", dependent: :destroy
  has_many :commenters, through: :comments, source: :commenter
  has_many :fans, through: :likes, source: :fan

end
