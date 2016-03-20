class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :omniauthable,
  # :recoverable and :rememberable
  devise :database_authenticatable, :registerable,
         :trackable, :validatable
end
