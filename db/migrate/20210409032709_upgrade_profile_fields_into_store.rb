class UpgradeProfileFieldsIntoStore < ActiveRecord::Migration[6.1]
  def up
    coder = ActiveRecord::Coders::YAMLColumn.new(:foo, Object)

    records = execute("select * from profiles")
    records.each do |record|
      if record["contacts"].start_with?("\"---")
        contacts = coder.load(YAML.safe_load(record["contacts"]))
        execute ActiveRecord::Base.send(:sanitize_sql_array, ["update profiles set contacts = ? where id = ?", contacts.to_json, record["id"]])
      end

      if record["rewards"].start_with?("\"---")
        rewards = coder.load(YAML.safe_load(record["rewards"]))
        execute ActiveRecord::Base.send(:sanitize_sql_array, ["update profiles set rewards = ? where id = ?", rewards.to_json, record["id"]])
      end
    end
  end
end
