APP_KEY = "dw71fn6jh7pk8l8"
APP_SECRET = "fdz4reon76aawt3"
OAUTH_URL = "https://www.dropbox.com/oauth2/authorize"
TOKEN_API = "https://api.dropboxapi.com/oauth2/token"
TOKEN_FILE = Dir.home + "/.config/weddingexpo/dropbox"
LIST_API = "https://api.dropboxapi.com/2/files/list_folder"
DOWNLOAD_API = "https://content.dropboxapi.com/2/files/download"
CACHE_DIR = "tmp/cache/snapshots"

def die(msg)
  puts "\033[31;1m#{msg}.\033[0m"
  exit 1
end

# Gets a Dropbox access token via OAuth
def get_access_token
  if File.exist?(TOKEN_FILE)
    return File.open(TOKEN_FILE) { |f| f.readline }.chomp
  end

  system "open #{OAUTH_URL}?response_type=code\\&client_id=#{APP_KEY}\\&require_role=work"
  print "Enter token: "
  auth_token = STDIN.noecho(&:gets).chomp
  puts

  resp = HTTP.basic_auth(user: APP_KEY, pass: APP_SECRET).post(TOKEN_API, form: {code: auth_token, grant_type: "authorization_code"})
  access_token = JSON.parse(resp)["access_token"]
  die("Access denied") unless access_token

  dir = Dir.home + "/.config/weddingexpo"
  Dir.mkdir(dir) unless Dir.exist?(dir)
  File.open(TOKEN_FILE, "w+") { |f| f.puts(access_token) }
  return access_token
end

# Downloads a snapshot from Dropbox to tmp/cache/snapshots
def download_snapshot
  dbx = Dropbox::Client.new(get_access_token())

  files = dbx.list_folder("/Wedding\ Expo\ Team\ Folder/Snapshots").sort { |a, b| a.name <=> b.name }

  die("No snapshots found") if files.length == 0
  puts "Downloading snapshot..."
  file = files.last
  metadata, content = dbx.download(file.id)

  system "mkdir -p #{CACHE_DIR}"
  temp_path = "#{CACHE_DIR}/#{file.name}"
  File.open(temp_path, "wb") do |file|
	  content.each do |data|
		  file.write(data)
		end
	end

	return temp_path, file.name
end

namespace :db do
  # Downloads and imports an encryted database snapshot from Dropbox
  task restore: :environment do
    if ARGV[1] == "-c" && Dir.exist?(CACHE_DIR) && Dir.entries(CACHE_DIR).length > 2
      puts "Using cached snapshot."
      entries = Dir.entries(CACHE_DIR)
      temp_path = filename = "#{CACHE_DIR}/#{entries.last}"
    else
      temp_path, filename = download_snapshot()
    end

		host = Rails.configuration.database_configuration[Rails.env]["host"]
    user = Rails.configuration.database_configuration[Rails.env]["username"] || ENV["USER"]
    system "bin/restore_db #{host} #{user} #{temp_path} #{filename}"
  end

  # Synchronize the primary key sequence of every table
  task :seq => :environment do
    puts " TABLE            | MAX ID    "
    puts "------------------------------"
    conn = ActiveRecord::Base.connection
    tables = conn.tables
    tables.each do |table|
      begin
        val = conn.execute("SELECT SETVAL('#{table}_id_seq', (SELECT MAX(id) FROM #{table}))")
        if val[0]["setval"].to_s == ""
          val = conn.execute("ALTER SEQUENCE #{table}_id_seq RESTART")
          printf(" %-16s   %-6s\n", table, "0")
        else
          printf(" %-16s   %-6s\n", table, val[0]["setval"].to_s)
        end
      rescue ActiveRecord::StatementInvalid => e
      end
    end
  end
end
