class String
  def titleize
    split('-').join(' ').split(/(\W)/).map(&:capitalize).join
  end
end
