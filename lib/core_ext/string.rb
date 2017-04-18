class String
  # Strip out commas and line breaks from the string.
  def escape_csv
    gsub(/[,'\n]/, '').html_safe
  end
end
