
module V3
  class Notifications < Grape::API
    resources :notifications do
      before do
        doorkeeper_authorize!
      end
      
      desc %(获取当前用户的通知列表。
**NOTE**:（此接口不会将取到的通知设成已读，你需要调用一下 /notifications/read）

### Returns:

```json
{
    "notifications": [
        {
            "id": 394354,
            "type": "Topic",
            "read": true,
            "actor": {
                "id": 35,
                "login": "monster",
                "name": null,
                "avatar_url": "http://gravatar.com/avatar/dba7c3f68c94ec5f7ac96d0a5e7db205.png?s=120"
            },
            "mention_type": null,
            "mention": null,
            "reply": null,
            "created_at": "2015-05-12T22:08:53.542+08:00",
            "updated_at": "2015-05-18T20:50:26.393+08:00"
        },
        {
            "id": 394251,
            "type": "TopicReply",
            "read": true,
            "actor": {
                "id": 35,
                "login": "monster",
                "name": null,
                "avatar_url": "http://gravatar.com/avatar/dba7c3f68c94ec5f7ac96d0a5e7db205.png?s=120"
            },
            "mention_type": null,
            "mention": null,
            "reply": {
                "id": 256170,
                "body_html": "<p>asdgasdgasdgasdgasdg</p>",
                "created_at": "2015-05-12T16:24:07.284+08:00",
                "updated_at": "2015-05-12T16:24:07.284+08:00",
                "deleted": false,
                "topic_id": 25261
            },
            "created_at": "2015-05-12T16:24:07.319+08:00",
            "updated_at": "2015-05-18T20:50:26.393+08:00"
        },
    ]
}
```
)
      params do
        optional :offset, type: Integer, default: 0
        optional :limit, type: Integer, default: 20, values: 1..150
      end
      get "", each_serializer: NotificationSerializer, root: "notifications" do
        @notifications = current_user.notifications.recent.offset(params[:offset]).limit(params[:limit])
        render @notifications
      end
      
      desc "将当前用户的一些通知设成已读状态"
      params do
        requires :ids, type: Array
      end
      post "read" do
        if params[:ids].length > 0
          @notifications = current_user.notifications.where(:_id.in => params[:ids])
          current_user.read_notifications(@notifications)
        end
        { ok: 1 }
      end

      desc "删除当前用户的所有通知"
      delete "all" do
        current_user.notifications.delete_all
        { ok: 1 }
      end

      desc "删除当前用户的某个通知"
      delete ":id" do
        @notification = current_user.notifications.find params[:id]
        @notification.destroy
        { ok: 1 }
      end
    end
  end
end