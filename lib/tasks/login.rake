def login_as(user)
  verifier = ActiveSupport::MessageVerifier.new(Rails.application.secrets[:secret_key_base])
  token = verifier.generate(user.id)
  #system "open http://localhost:3000/login?token=#{token}"
  system "xdg-open http://localhost:3000/login?token=#{token}"
end

# Log in as an admin with the given email.
task :login => :environment do
  ARGV.each { |a| task a.to_sym do ; end }

  unless Rails.env.development?
    puts "Only available in development environment!"
    exit(1)
  end

  user = User.find_by(email: ARGV[1])
  puts "Logging in as #{user} (Admin)"
  login_as(user)
end