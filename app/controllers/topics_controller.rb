class TopicsController < ApplicationController
  autocomplete :topic, :title, :full => true
end