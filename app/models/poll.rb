class Poll
  # default expires in about 3 months
  DEFAULT_EXPIRES_IN = 90
  # maximum options in a poll
  MAXIMUM_OPTIONS = 32

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::BaseModel
  include Mongoid::SoftDelete

  # multiple chooses?
  field :multiple_mode, type: Mongoid::Boolean, default: false
  # for hide or show voters?
  field :public_mode, type: Mongoid::Boolean, default: false

  # expires in N days
  # when 0 means never be expired
  field :expires_in, type: Integer, default: DEFAULT_EXPIRES_IN

  # total voters count for single mode
  # total votes count for multiple mode
  field :total_voters_count, type: Integer, default: 0

  embeds_many :options, class_name: 'VoteOption' do
    def match(oid)
      where(oid: oid).first
    end
  end

  validate :limit_options_count, on: :create

  scope :for_topic, ->(tid) { without('options.voters').where(topic_id: tid) }

  belongs_to :topic, inverse_of: :poll

  index topic_id: 1

  # expired polls be not available / votable
  def votable?
    if expires_in == 0 || (created_at + expires_in.days) > Time.now
      return true
    end
    false
  end

  def voted_by?(user)
    user_id = user.is_a?(User) ? user.id : user
    Poll.where(_id: id).elem_match(options: { voters: user_id }).first && true
  end

  # vote for option(s) by user
  def vote(user, *oids)
    user_id = user.is_a?(User) ? user.id : user
    if votable? && !voted_by?(user_id)
      if multiple_mode
        vote_multi(user_id, oids)
      else
        vote_single(user_id, oids[0])
      end
      update_percentage
      return save
    else
      return false
    end
  end

  private

  def vote_single(user_id, oid)
    option = options.match(oid.to_i)
    if option
      option.voters << user_id
      option.voters_count += 1
      self.total_voters_count += 1
    end
  end

  def vote_multi(user_id, oids)
    oids.each do |i|
      vote_single(user_id, i)
    end
  end

  def update_percentage
    options.each do |o|
      new_percent = o.voters_count.to_f / total_voters_count.to_f
      o.percent = (new_percent * 100.0).round(2)
    end
  end

  # before save
  def limit_options_count
    errors.add(:poll, 'Not enough options') if options.size < 2
    errors.add(:poll, 'Too many options') if options.size >= MAXIMUM_OPTIONS
  end
end
