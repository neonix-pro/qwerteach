module AdvertsHelper
  def adverts_layout n
    case n
      when 1
        ['simple']
      when 2
        ['double', 'double']
      when 3
        ['triple', 'triple', 'triple']
      when 4
        adverts_layout(3) + ["br"] + adverts_layout(1)
      when 5
        adverts_layout(2)  + ["br"] + adverts_layout(3)
      else
        r = adverts_layout(2)
        l = n-2
        while (l>0)
          line = 1 + Random.rand(3)
          r += ["br"] + adverts_layout([line, l].min)
          l -= line
        end
        return r
    end

  end

end
