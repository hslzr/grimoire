module ApplicationHelper

  def bg_for_flash(key)
    case key
    when 'notice'
      'bg-green-500'
    when 'alert'
      'bg-red-500'
    else
      'bg-gray-500'
    end
  end
end
