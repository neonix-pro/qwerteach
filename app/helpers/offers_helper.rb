module OffersHelper
  def offers_layout n
    case n
      when 1
        ['simple']
      when 2
        ['double', 'double']
      when 3
        ['triple', 'triple', 'triple']
      when 4
        offers_layout(3) + ["br"] + offers_layout(1)
      when 5
        offers_layout(2)  + ["br"] + offers_layout(3)
      else
        r = offers_layout(2)
        l = n-2
        while (l>0)
          line = 1 + Random.rand(3)
          r += ["br"] + offers_layout([line, l].min)
          l -= line
        end
        return r
    end

  end

end
