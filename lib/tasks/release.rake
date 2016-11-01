if Rails.env.development? || Rails.env.test?
  task :release do
    version = Homeland.version
    version_tag = "v#{version}"

    guard_clean

    begin
      sh "git tag -m \"Version #{version}\" #{version_tag}"
      puts "Tagged #{version_tag}."
    rescue
      "Untagging #{version_tag} due to error."
      sh "git tag -d #{version_tag}"
    end

    return false if not `git tag`.split(/\n/).include?(version_tag)
    puts "Tag #{version_tag} has already been created."

    git_push('origin')
  end
end

def git_push(remote = "")
  perform_git_push remote
  perform_git_push "#{remote} --tags"
  puts "Pushed git commits and tags."
end

def perform_git_push(options = "")
  cmd = "git push #{options}"
  out, code = sh_with_code(cmd)
  raise "Couldn't git push. `#{cmd}' failed with the following output:\n\n#{out}\n" unless code == 0
end

def sh(cmd)
  out, code = sh_with_code(cmd, &block)
  unless code.zero?
    raise(out.empty? ? "Running `#{cmd}` failed. Run this command directly for more detailed output." : out)
  end
  out
end

def sh_with_code(cmd, &block)
  cmd += " 2>&1"
  outbuf = `#{cmd}`
  status = $?.exitstatus
  block.call(outbuf) if status.zero? && block
  [outbuf, status]
end

def guard_clean
  clean? && committed? || raise("There are files that need to be committed first.")
end

def clean?
  sh_with_code("git diff --exit-code")[1] == 0
end

def committed?
  sh_with_code("git diff-index --quiet --cached HEAD")[1] == 0
end