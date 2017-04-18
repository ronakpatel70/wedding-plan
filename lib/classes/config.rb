class Config
  FILES = Dir.glob('lib/config/*.yml').map do |f|
    [f.split('/').last.chomp('.yml'), YAML.load_file(f).with_indifferent_access]
  end.to_h

  private
    def self.method_missing(symbol, *args)
      key = symbol.to_s
      raise NoMethodError, "undefined method `#{key}' for #{self}:Class" unless FILES.has_key?(key)
      return FILES[key]
    end
end
