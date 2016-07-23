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
end
