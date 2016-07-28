module UsersHelper
  def profile_advert_classes n
    case n
      when 1
        'simple'
      when 2
        'double'
      when 3
        'triple'
      when 4
        'quadruple'
      else
    end

  end

  def popular_topics
    @popular_topics ||= Advert.group(:topic).order('count_id DESC').limit(5).count(:id).map{|topic| topic.first}
  end

  def search_total_results(pagin)
    case pagin.total_count
      when 0
        "Oh zut! Il semblerait qu'il n'y ait pas de prof de "
      when 1
        "#{pagin.total_count} prof trouvé pour "
      else
        "#{pagin.total_count} profs trouvés pour "
    end
  end

  def search_topic_options
    @topic_options = Topic.where.not(:title=> "Other").map{|p| [p.title.downcase]}
  end

  def search_sorting_name
    @sorting_options.each do |sort|
      return @search_sorting_name ||=  sort[0] if sort[1] == params[:search_sorting]
    end
    @search_sorting_name ||= "pertinence"
  end
end
