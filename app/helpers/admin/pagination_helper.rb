module Admin
  module PaginationHelper
    def paginate_admin(scope, options = {})
      paginate(scope, options.merge(theme: 'bootstrap4'))
    end
  end
end