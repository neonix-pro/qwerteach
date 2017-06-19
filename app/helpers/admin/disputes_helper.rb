module Admin
  module DisputesHelper

    def scopes
      @scopes ||= DisputeDashboard::COLLECTION_SCOPES.each_with_object({}) do |name, hash|
        hash[name] = [
          t("admin.despute.scope.#{name}", default: name),
          q: {name => true}
        ]
      end
    end

  end
end