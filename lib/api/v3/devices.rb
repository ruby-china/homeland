module API
  module V3
    class Devices < Grape::API
      resource :devices do

        desc '记录用户 Device 信息，用于 Push 通知。
        请在每次用户打开 App 的时候调用此 API 以便更新 Token 的 last_actived_at 让服务端知道这个设备还活着。
        Push 将会忽略那些超过两周的未更新的设备。'
        params do
          requires :platform, type: String, values: %w(ios android)
          requires :token, type: String
        end
        post '' do
          doorkeeper_authorize!

          @device = current_user.devices.find_or_initialize_by(platform: params[:platform].downcase, token: params[:token])
          @device.last_actived_at = Time.now
          if @device.save
            { ok: 1 }
          else
            error!({ error: @device.errors.full_messages }, 400)
          end
        end

        desc '删除 Device 信息，请注意在用户登出或删除应用的时候调用，以便能确保清理掉'
        params do
          requires :platform, type: String, values: %w(ios android)
          requires :token, type: String
        end
        delete '' do
          doorkeeper_authorize!
          current_user.devices.where(platform: params[:platform].downcase, token: params[:token]).delete_all
          { ok: 1 }
        end
      end
    end
  end
end
