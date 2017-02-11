namespace :upgrade do
  desc 'Updates the ruby-advisory-db and runs audit'
  task action_store: :environment do
    Action.delete_all
    copy_data_from_users
    puts "== Import User done, Action on #{Action.last.id}"
    copy_data_from_topics
    puts "== Import Topic done, Action on #{Action.last.id}"
    copy_data_from_replies
    puts "== Import Reply done, Action on #{Action.last.id}"
    # Check data
  end
end

def copy_data_from_topics
  Topic.unscoped.where('
    array_length(liked_user_ids, 1) > 0 OR
    array_length(follower_ids, 1) > 0
  ').find_in_batches do |group|
    group.each do |t|
      Action.bulk_insert(set_size: 100) do |worker|
        default_action = {
          target_type: 'Topic',
          target_id: t.id,
          user_type: 'User'
        }

        puts "Topic:#{t.id} follow users"
        t[:follower_ids].each do |uid|
          puts "  Add #{uid}"
          action = default_action.merge(action_type: 'follow', user_id: uid)
          worker.add(action)
        end

        puts "Topic:#{t.id} liked users"
        t[:liked_user_ids].each do |uid|
          puts "  Add #{uid}"
          action = default_action.merge(action_type: 'like', user_id: uid)
          worker.add(action)
        end
      end
      t.update_columns(likes_count: t[:liked_user_ids].count)
    end
  end
end

def copy_data_from_replies
  Reply.unscoped.where('
    array_length(liked_user_ids, 1) > 0
  ').find_in_batches do |group|
    group.each do |r|
      Action.bulk_insert(set_size: 100) do |worker|
        default_action = {
          target_type: 'Reply',
          target_id: r.id,
          user_type: 'User'
        }

        puts "Reply:#{r.id} liked users"
        r[:liked_user_ids].each do |uid|
          puts "  Add #{uid}"
          action = default_action.merge(action_type: 'like', user_id: uid)
          worker.add(action)
        end
      end
      r.update_columns(likes_count: r[:liked_user_ids].count)
    end
  end
end

def copy_data_from_users
  User.unscoped.where('
    type is null AND
    (array_length(following_ids, 1) > 0 OR
    array_length(follower_ids, 1) > 0 OR
    array_length(blocked_user_ids, 1) > 0 OR
    array_length(blocked_node_ids, 1) > 0 OR
    array_length(favorite_topic_ids, 1) > 0)
  ').find_in_batches do |group|
    group.each do |u|
      Action.bulk_insert(set_size: 100) do |worker|
        # following_ids
        default_action = {
          action_type: 'follow',
          target_type: 'User',
          user_type: 'User',
          user_id: u.id
        }
        puts "User:#{u.id} follow users"
        u[:following_ids].each do |uid|
          puts "  Add to: #{uid}"
          action = default_action.merge(target_id: uid)
          worker.add(action)
        end
        u.update_columns(followers_count: u[:follower_ids].count, following_count: u[:following_ids].count)

        # block_user_ids
        default_action = {
          action_type: 'block',
          target_type: 'User',
          user_type: 'User',
          user_id: u.id
        }
        puts "User:#{u.id} block users"
        u[:blocked_user_ids].each do |uid|
          puts "  Add to: #{uid}"
          action = default_action.merge(target_id: uid)
          worker.add(action)
        end

        # blocked_node_ids
        default_action = {
          action_type: 'block',
          target_type: 'Node',
          user_type: 'User',
          user_id: u.id
        }
        puts "User:#{u.id} block users"
        u[:blocked_node_ids].each do |node_id|
          puts "  Add to: #{node_id}"
          action = default_action.merge(target_id: node_id)
          worker.add(action)
        end

        # favorite_topic_ids
        default_action = {
          action_type: 'favorite',
          target_type: 'Topic',
          user_type: 'User',
          user_id: u.id
        }
        puts "User:#{u.id} favorite topics"
        u[:favorite_topic_ids].each do |topic_id|
          puts "  Add to: #{topic_id}"
          action = default_action.merge(target_id: topic_id)
          worker.add(action)
        end
      end
    end
  end
end