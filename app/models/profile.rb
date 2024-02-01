class Profile < ApplicationRecord
  belongs_to :user
  has_one :personal_info, dependent: :destroy
  has_many :professional_infos, dependent: :destroy
  has_many :education_infos, dependent: :destroy
  has_many :profile_job_categories, dependent: :destroy

  has_many :followers, class_name: 'Connection', foreign_key: :followed_profile_id, dependent: :destroy,
                       inverse_of: :follower

  has_many :followed_profiles, class_name: 'Connection', foreign_key: :follower_id,
                               dependent: :destroy, inverse_of: :followed_profile

  has_many :connections, foreign_key: :followed_profile_id, dependent: :destroy, inverse_of: :followed_profile

  has_many :job_categories, through: :profile_job_categories

  accepts_nested_attributes_for :personal_info
  accepts_nested_attributes_for :professional_infos
  accepts_nested_attributes_for :education_infos

  after_create :create_personal_info!
  enum work_status: { unavailable: 0, open_to_work: 10 }

  delegate :full_name, to: :user

  def self.advanced_search(search_query)
    left_outer_joins(:job_categories, :personal_info, :user).where(
      "job_categories.name LIKE :term OR
                 personal_infos.city LIKE :term OR
                 users.full_name LIKE :term", { term: "%#{sanitize_sql_like(search_query)}%" }
    ).uniq
  end

  def self.get_profile_job_categories_json(query)
    profiles = search_by_job_categories(query)
    profiles_json = profiles.map do |profile|
      { user_id: profile.user_id, full_name: profile.full_name,
        job_categories: ProfileJobCategory.generate_profile_job_categories_json(profile.id) }
    end
    profiles_json.as_json
  end

  def followers_count
    followers.active.count
  end

  def followed_count
    followed_profiles.active.count
  end

  def following?(profile)
    followers.active.where(follower: profile).any?
  end

  def inactive_follower?(profile)
    followers.inactive.where(follower: profile).any?
  end

  def self.most_followed(limit)
    joins(:followers)
      .where(connections: { status: 'active' })
      .group(:id)
      .order('count(follower_id) DESC, id ASC')
      .limit(limit)
  end
end

private

def search_by_job_categories(query)
  left_outer_joins(:job_categories, :profile_job_categories).where(
    "job_categories.name LIKE :term OR
               profile_job_categories.description LIKE :term", { term: "%#{sanitize_sql_like(query)}%" }
  ).uniq
end
