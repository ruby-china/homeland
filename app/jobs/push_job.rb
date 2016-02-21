class PushJob < ApplicationJob
  queue_as :notifications

  # user_ids: 用户编号列表
  # note: { alert: 'Hello APNS World!', sound: 'true', badge: 1 }
  def perform(user_ids, note = {})
    return false if SiteConfig.apns_pem.blank?

    note[:sound] ||= 'true'
    devices = Device.where(user_id: user_ids).all.to_a
    devices.reject! { |d| !d.alive? }
    tokens = devices.collect(&:token)
    return false if tokens.blank?

    notification = RubyPushNotifications::APNS::APNSNotification.new tokens, { aps: note }
    pusher = RubyPushNotifications::APNS::APNSPusher.new(SiteConfig.apns_pem, !Rails.env.production?)
    pusher.push [notification]
    Rails.logger.tagged("PushJob") { Rails.logger.info "send to #{tokens.size} devices #{note} status: #{notification.success}"  }
    notification.success
  end
end
