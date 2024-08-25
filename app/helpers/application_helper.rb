module ApplicationHelper
  def svg(file)
    File.open("app/assets/images/#{file}.svg", "rb") do |file|
      raw file.read
    end
  end

  def bg_for_flash(key)
    case key
    when 'notice'
      'bg-teal-600'
    when 'alert'
      'bg-red-500'
    else
      'bg-gray-500'
    end
  end
end
