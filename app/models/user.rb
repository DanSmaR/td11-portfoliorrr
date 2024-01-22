require 'cpf_cnpj'

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_one :profile, dependent: :destroy
  has_one :personal_info, through: :profile
  has_many :posts, dependent: :destroy

  enum role: { user: 0, admin: 10 }

  validates :full_name, :citizen_id_number, presence: true
  validates :citizen_id_number, uniqueness: true
  validate :validate_citizen_id_number

  after_create :'create_profile!'

  def self.search_by_full_name(query)
    where('full_name LIKE ?',
          "%#{sanitize_sql_like(query)}%")
  end

  private

  def validate_citizen_id_number
    errors.add(:citizen_id_number, 'inválido') unless CPF.valid?(citizen_id_number)
  end
end
