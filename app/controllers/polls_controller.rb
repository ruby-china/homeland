require 'will_paginate/array'

class PollsController < ApplicationController
  before_filter :require_user, only: [:update]
  before_filter :find_poll

  def voters
    @users = Rails.cache.read(cache_key_for_voters) if Rails.env.production?
    if @users.nil?
      @users = User.only(:_id, :name, :avatar, :email_md5, :login)
               .where(_id: { '$in' => voters_ids })
               .paginate(page: params[:page], per_page: 50)
      if Rails.env.production?
        Rails.cache.write(cache_key_for_voters, @users, expires_in: 6.hours)
      end
    end
    render layout: false
  end

  # vote
  def update
    status = {}
    voted = @poll.vote(current_user, *options_params)
    if voted
      status[:voted] = true
    else
      status[:msg] = 'Poll was voted or not votable.'
    end
    render json: status
  end

  private

  # => ["1", "2", "3"]
  def options_params
    params.require(:oids)
  end

  def find_poll
    id = params[:id]
    @poll = Poll.find(id)
  end

  def voters_ids
    oid = params[:oid].to_i
    ids = @poll.options.match(oid).try(:voters) || []
    ids
  end

  def cache_key_for_voters
    # refresh by total_voters_count
    "/polls/#{@poll.id}/voters/#{params[:oid]}/#{params[:page]}/" \
    "#{@poll.total_voters_count}"
  end
end
