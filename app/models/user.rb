# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  comments_count         :integer
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  likes_count            :integer
#  private                :boolean
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  username               :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

         validates :username, presence: true
         validates :username, uniqueness: true

         has_many  :comments, class_name: "Comment", foreign_key: "author_id", dependent: :destroy
         has_many  :own_photos, class_name: "Photo", foreign_key: "owner_id", dependent: :destroy
         has_many  :likes, class_name: "Like", foreign_key: "fan_id", dependent: :destroy
         
         has_many  :received_follow_requests, class_name: "FollowRequest", foreign_key: "recipient_id", dependent: :destroy
         has_many  :sent_follow_requests, class_name: "FollowRequest", foreign_key: "sender_id", dependent: :destroy
         has_many :accepted_sent_follow_requests, -> { where(status: 'accepted') }, class_name: "FollowRequest", foreign_key: "sender_id"
         has_many :accepted_received_follow_requests, -> { where(status: 'accepted') }, class_name: "FollowRequest", foreign_key: "recipient_id"
       
         # Define the :followers and :leaders associations through the accepted follow requests
         has_many(:followers, through: :accepted_received_follow_requests, source: :sender)
         has_many(:leaders, through: :accepted_sent_follow_requests, source: :recipient)
       
         # ... [other code] ...
  
         has_many(:commented_photos, through: :comments, source: :photo)
         has_many(:liked_photos, through: :likes, source: :photo)

        # def accepted_sent_follow_requests
         # my_sent_follow_requests = self.sent_follow_requests
          
         # matching_follow_requests = my_sent_follow_requests.where({ :status => "accepted" })
          
         # return matching_follow_requests
        #end

        #def accepted_received_follow_requests
         # my_received_follow_requests = self.received_follow_requests
       
          # matching_follow_requests = my_received_follow_requests.where({ :status => "accepted" })
       
          # return matching_follow_requests
        # end
         
         def feed
          array_of_photo_ids = Array.new
      
          my_leaders = self.leaders
          
          my_leaders.each do |a_user|
            leader_own_photos = a_user.own_photos
      
            leader_own_photos.each do |a_photo|
              array_of_photo_ids.push(a_photo.id)
            end
          end
      
          matching_photos = Photo.where({ :id => array_of_photo_ids })
      
          return matching_photos
        end
      
        def discover
          array_of_photo_ids = Array.new
      
          my_leaders = self.leaders
          
          my_leaders.each do |a_user|
            leader_liked_photos = a_user.liked_photos
      
            leader_liked_photos.each do |a_photo|
              array_of_photo_ids.push(a_photo.id)
            end
          end
      
          matching_photos = Photo.where({ :id => array_of_photo_ids })
      
          return matching_photos
        
        end
         
         # has_many(:feed, through: :leaders.own_photos, source: :photo)
         # has_many(:discover, through: :leaders.liked_photos, source: :photo)

      end
