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

  embeds_many :options, class_name: "VoteOption" do
    def match(oid)
      where(oid: oid).first
    end
  end

  validate :limit_options_count, on: :create

  scope :for_topic, ->(topic_id) {without("options.voters").where(topic_id: topic_id)}

  belongs_to :topic, inverse_of: :poll

  index topic_id: 1

  # expired polls be not available / votable
  def votable?
    if self.expires_in == 0 || (self.created_at + self.expires_in.days) > Time.now
      return true
    end
    return false
  end

  def voted_by?(user)
    user_id = user.is_a?(User) ? user.id : user
    # !!self.options.detect{ |o| o.voters.include?(user_id) }
    !!Poll.where(_id: self.id).elem_match(options: {voters: user_id}).first
  end

  # vote for option(s) by user
  def vote(user, *oids)
    user_id = user.is_a?(User) ? user.id : user
    if votable? && !voted_by?(user_id)
      if self.multiple_mode
        vote_multi(user_id, oids)
      else
        vote_single(user_id, oids[0])
      end
      update_percentage
      return self.save
    else
      return false
    end
  end

  private

  def vote_single(user_id, oid)
    option = self.options.match(oid.to_i)
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
    self.options.each do |o|
      new_percent = o.voters_count.to_f/self.total_voters_count.to_f
      o.percent = (new_percent * 100.0).round(2)
    end
  end

  # before save
  def limit_options_count
    errors.add(:poll, "Not enough options") if self.options.size < 2
    errors.add(:poll, "Too many options") if self.options.size >= MAXIMUM_OPTIONS
  end

end
