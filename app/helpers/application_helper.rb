module ApplicationHelper

  def title
    base_title = "Ruby On Rails Tutorial : Sample App"
    if @title 
      title = "#{base_title} | #{@title}"
    else
      title =  base_title
    end 
  end
end
