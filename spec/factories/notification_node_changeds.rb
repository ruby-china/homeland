FactoryBot.define do
  factory :notification_node_changed, parent: :notification do
    notify_type 'node_changed'
    association :target, factory: :topic
    association :second_target, factory: :node
  end
end
