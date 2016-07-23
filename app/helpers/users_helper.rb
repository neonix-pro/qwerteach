module UsersHelper
  def profile_advert_classes n
    case n
      when 1
        ['simple']
      when 2
        ['double', 'double']
      when 3
        ['simple', 'double', 'double']
      when 4
        ['simple', 'triple', 'triple', 'triple']
      when 5
        ['double', 'double', 'triple', 'triple', 'triple']
      else
        r= profile_advert_classes(2)
        c = n - 2
        while c > 0
          t = rand(1..[5, c].min)
          r += profile_advert_classes(t)
          c -= t
        end
        r
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
end
