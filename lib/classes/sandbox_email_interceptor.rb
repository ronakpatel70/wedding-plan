class SandboxEmailInterceptor
  def self.delivering_email(message)
    devs = ['pianoman320@me.com',
            'wbdorange@gmail.com',
            'webmaster@winecountrybride.com',
            'acousens@gmail.com',
            'acousens.wcb@gmail.com',
            'a.cousens@me.com',
            'dylan@waits.io']
    unless message.to.count == 1 and devs.include? message.to.first
      message.to = ['success@simulator.amazonses.com']
    end
  end
end
