require 'test_helper'

class PollTest < ActiveSupport::TestCase
  def setup
    @option1 = build(:option)
    @option2 = build(:option)
    @poll = create(:poll, options: [@option1, @option2])
    @user1 = 1
    @user2 = 2
    @user3 = 3
  end

  test 'default init' do
    assert_equal false, @poll.multiple_mode
    assert_equal false, @poll.public_mode
    assert_equal Poll::DEFAULT_EXPIRES_IN, @poll.expires_in
    assert_equal 0, @poll.total_voters_count
    assert_equal 2, @poll.options.count
    assert @poll.votable?
  end

  test 'should be expired' do
    @poll.update_attribute :expires_in, -1
    assert !@poll.votable?
  end

  test 'should be available' do
    @poll.update_attribute :expires_in, 0
    assert @poll.votable?
  end

  test 'should be voted by' do
    @poll.vote @user2, @option1.oid
    assert @poll.voted_by?(@user2)
    assert !@poll.voted_by?(@user1)
  end

  test 'single vote option' do
    @poll.vote @user1, @option1.oid
    assert @poll.voted_by?(@user1)
    assert_equal 100.0, @poll.options.match(@option1.oid).percent
    assert_equal 1, @poll.options.match(@option1.oid).voters_count
    assert_equal 1, @poll.total_voters_count
  end

  test 'should not be re-vote' do
    @poll.vote @user1, @option1.oid
    # @user1 is voted
    @poll.vote @user1, @option1.oid
    @poll.vote @user1, @option2.oid
    @poll.vote @user1, @option2.oid
    assert_equal 100.0, @poll.options.match(@option1.oid).percent
    assert_equal 1, @poll.options.match(@option1.oid).voters_count
    assert_equal 0, @poll.options.match(@option2.oid).percent
    assert_equal 0, @poll.options.match(@option2.oid).voters_count
    assert_equal 1, @poll.total_voters_count
  end

  test 'multi users vote option' do
    new_option = build(:option)
    @poll.options << new_option
    users = (1..5).to_a
    users.each do |user|
      @poll.vote user, new_option.oid
    end
    assert_equal 100.0, @poll.options.match(new_option.oid).percent
    assert_equal users.size, @poll.options.match(new_option.oid).voters_count
    assert_equal users.size, @poll.total_voters_count
  end

  test 'multi users vote different options' do
    option3 = build(:option)
    @poll.options << option3
    user4 = 4
    user5 = 5
    @poll.vote @user1, @option1.oid
    @poll.vote @user2, @option1.oid
    @poll.vote @user3, @option2.oid
    @poll.vote user4, @option2.oid
    @poll.vote user5, option3.oid
    # 2:2:1
    assert_equal 2, @poll.options.match(@option1.oid).voters_count
    assert_equal 2, @poll.options.match(@option2.oid).voters_count
    assert_equal 1, @poll.options.match(option3.oid).voters_count
    assert_equal 40.0, @poll.options.match(@option1.oid).percent
    assert_equal 40.0, @poll.options.match(@option2.oid).percent
    assert_equal 20.0, @poll.options.match(option3.oid).percent
    assert_equal 5, @poll.total_voters_count
  end

  test 'multiple mode' do
    option3 = build(:option)
    @poll.options << option3
    @poll.update_attribute :multiple_mode, true
    @poll.vote @user1, @option1.oid, @option2.oid, option3.oid
    # 1:1:1
    assert_equal 3, @poll.total_voters_count
    assert_equal 33.33, @poll.options.match(@option1.oid).percent
    assert_equal 33.33, @poll.options.match(@option2.oid).percent
    assert_equal 33.33, @poll.options.match(option3.oid).percent

    @poll.vote @user2, option3.oid, @option1.oid
    # 2:1:2
    assert_equal 5, @poll.total_voters_count
    assert_equal 40.0, @poll.options.match(@option1.oid).percent
    assert_equal 20.0, @poll.options.match(@option2.oid).percent
    assert_equal 40.0, @poll.options.match(option3.oid).percent
  end

  test 'Not enough options' do
    # at least 2 options
    option = build(:option)
    poll = Poll.create(options: [option])
    assert poll.errors.any?
    assert_equal "Not enough options", poll.errors.messages[:poll][0]
  end

  test 'Too many options' do
    n = Poll::MAXIMUM_OPTIONS + 1
    opts = []
    n.times do |o|
      opts << {oid: o, description: "opt #{o}"}
    end
    poll = Poll.create(options: opts)
    assert poll.errors.any?
    assert_equal "Too many options", poll.errors.messages[:poll][0]
  end

end
