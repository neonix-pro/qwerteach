module Admin
  module TabsHelper

    def tab_state(tab, default = false)
      return :active if default and params[:tab].blank?
      params[:tab] == tab ? :active : :inactive
    end

  end
end