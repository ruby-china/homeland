namespace :like do
  desc "remove all likes that doesn't actually like anything"
  task :cleanup => [:environment] do
    Like.all.each do |like|
      if like.likeable == nil
        # outputs "Broken: User@name <- Like#X -> Type#Y"
        $stdout.puts "Broken: User@#{like.user.login} <- Like##{like.id} -> #{like.likeable_type}##{like.likeable_id}"
        like.destroy
      end
    end
  end
end