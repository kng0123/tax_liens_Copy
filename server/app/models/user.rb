class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable

  has_one :profile, dependent: :destroy

  has_one :profile
  accepts_nested_attributes_for :profile


  protected

  # def profile
  #   super || build_profile
  # end

end
