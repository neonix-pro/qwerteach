<% flash.each do |key, value| %>
    $('#flash-messages').append("<%= j render partial: 'shared/flash_dismiss', locals:{type: key, content: value} unless value.nil? %>");
<% end %>