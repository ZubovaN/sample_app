class User < ActiveRecord::Base
  attr_accessor :remember_token

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  #callback (hook)
  before_save { self.email = email.downcase }


  validates :name, length: { maximum: 50, minimum: 2 }

  validates :email, presence: true
  validates :email, allow_blank: true,
                    length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }

  has_secure_password
  validates :password, length: {minimum: 6}, allow_nil: true

  # Возвращает дайджест для указанной строки
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
               BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Возвращает случайный токен.
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  #создаем токен + записываем в бд дайджест токена
  # create_token_and_write_token_digest_to_DB
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  # сравниваем дайджест токена, который в бд, с токеном который пришел из куки
  def authenticated?(remember_token)
    return false if remember_digest.blank?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end
end
