class User < ActiveRecord::Base
  attr_accessor :remember_token, :activation_token

  before_save :downcase_email
  before_create :create_activation_digest

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

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
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")

    return false if digest.blank?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # Активирует учетную запись.
  def activate
    update_attribute(:activated, true)
    update_attribute(:activated_at, Time.zone.now)
  end

  # Посылает письмо со ссылкой на страницу активации.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  private

  def downcase_email
    self.email = email.downcase
  end

  # создаем токен и дайджест для подтверждения эмеила
  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
