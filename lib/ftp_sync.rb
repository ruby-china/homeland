#!/usr/bin/ruby
require 'net/ftp'
require 'date'
require 'fileutils'

# usage:

# ftp = FtpSync.new('ftp.site.com', 'user', 'password')
# ftp.sync('/Users/james/Desktop/test_ftp', '/home/james/Sites')
# ftp.copy_folder('/home/james/Sites/folder1', '/home/james/Sites/folder3')

# simple class to sync local directory to a remote ftp directory, or copy directories on remote server
class FtpSync
  def initialize(host, user, password, passive=FALSE)
    @host = host
    @user = user
    @password = password
    @passive = passive
  end
  
  # sync a local directory to a remote directory
  def sync(local_dir, remote_dir)
    ftp = Net::FTP.new(@host)
    begin
      ftp.login(@user, @password)
      ftp.passive = @passive
      puts "logged in, start syncing..."
      
      sync_folder(local_dir, remote_dir, ftp)
      
      puts "sync finished"
      
    rescue Net::FTPPermError => e
      puts "Failed: #{e.message}"
      return false
    end
  end
  
  # copy a remote directory to another location
  # dir_dest should not contain the final dir name, but its parent dir, .eg:
  # copy_folder('/home/james/test/folder', '/home/james/') will eventually create /home/james/folder
  def copy_folder(dir_source, dir_dest)
    ftp = Net::FTP.new(@host)
    begin
      ftp.login(@user, @password)
      ftp.passive = @passive
      puts "logged in, start copying #{dir_source} to #{dir_dest}..."
      
      #create a tmp folder locally
      tmp_folder = "tmp/ftp_sync"
      if not File.exist?(tmp_folder)
        FileUtils.mkdir tmp_folder
      end
      Dir.chdir tmp_folder
      
      #download whole folder
      ftp.chdir File.dirname(dir_source)
      target = File.basename(dir_source)
      download_folder(target, ftp)

      #upload to dest
      ftp.chdir dir_dest
      upload_folder(target, ftp)
      
      #todo delete local tmp folder
      Dir.chdir ".."
      FileUtils.rm_rf tmp_folder

      puts "copy finished"
    end    
  end
  
  private 
  def put_title(title)
    puts "#{title}"
  end
  
  def download_folder(remote_dir, ftp)
    ftp.chdir remote_dir   
    FileUtils.mkdir remote_dir
    Dir.chdir remote_dir
    
    dirs, files = get_remote_dir_and_file_names(ftp)
    
    dirs.each do |dir|
      download_folder(dir, ftp)
    end
    
    files.each do |file|
      ftp.get(file)
    end
    
    parent = ([".."] * (1 + remote_dir.count("/"))).join("/")
    Dir.chdir(parent)
    ftp.chdir(parent)
  end
  
  def full_file_path(file)
    File.join(Dir.pwd, file)
  end
  
  def upload_file(file, ftp)
    put_title "upload file: #{full_file_path(file)}"
    ftp.put(file)
  end
  
  def upload_folder(dir, ftp)
    put_title "upload folder: #{full_file_path(dir)}"
    Dir.chdir dir
    ftp.mkdir dir
    ftp.chdir dir
      
    local_dirs, local_files = get_local_dir_and_file_names
    
    local_dirs.each do |subdir|
      upload_folder(subdir, ftp)
    end
    
    local_files.each do |file|
      upload_file(file, ftp)
    end
    
    parent = ([".."] * (1 + dir.count("/"))).join("/")
    Dir.chdir(parent)
    ftp.chdir(parent)
  end
  
  def sync_folder(local_dir, remote_dir, ftp)
    Dir.chdir local_dir
    begin
      ftp.chdir remote_dir
    rescue
      # if the remote dir doesn't exist, we create it
      ftp.mkdir remote_dir
      ftp.chdir remote_dir
    end
    
    put_title "process folder: #{Dir.pwd}"
    
    local_dirs, local_files = get_local_dir_and_file_names
    remote_dirs, remote_files = get_remote_dir_and_file_names(ftp)

    new_dirs = local_dirs - remote_dirs
    new_files = local_files - remote_files
    existing_dirs = local_dirs - new_dirs
    existing_files = local_files - new_files
    
    # put_title "new dirs"
    # puts new_dirs
    # put_title "new files"
    # puts new_files
    # put_title "existing dirs"
    # puts existing_dirs
    # put_title "existing files"
    # puts existing_files
    
    new_files.each do |file|
      upload_file(file, ftp)
    end
    
    existing_files.each do |file|
      upload_file(file, ftp)
    end
    
    new_dirs.each do |dir|
      upload_folder(dir, ftp)
    end
    
    existing_dirs.each do |dir|
      sync_folder(dir, dir, ftp)
    end
    
    Dir.chdir(([".."] * (1 + local_dir.count("/"))).join("/"))
    ftp.chdir(([".."] * (1 + remote_dir.count("/"))).join("/"))
  end
  
  def get_local_dir_and_file_names
    dirs = []
    files = []
    Dir.glob("*").each do |file|
      if File.file?(file)
        files << file
      else
        dirs << file
      end
    end
    return [dirs, files]
  end
  
  def get_remote_dir_and_file_names(ftp)
    dirs = []
    files = []
    ftp.ls do |file|
      #-rw-r--r--    1 james     staff            6 Jan 07 03:54 hello.txt
      fname = file.gsub(/\S+\s+\d+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+/, '')
      case file[0, 1]
      when "-"
        files << fname
      when "d"
        dirs << fname
      end
    end
    return [dirs, files]
  end
end
