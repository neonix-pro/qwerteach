jQuery ->
  if $('#search-results').size() > 0
    $(window).on 'scroll', ->
      more_posts_url = $('.more-results-button a').attr('href')
      if more_posts_url && $(window).scrollTop() >  ($('#more-results').offset().top - 600 - $(window).height())
        $('.more-results-button').html('<i class="fa fa-spinner fa-spin"></i> Chargement')
        $.getScript more_posts_url
      return
  return