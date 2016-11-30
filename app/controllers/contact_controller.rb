class ContactController < ApplicationController
  def new
    @contact = Contact.new
  end

  def create
    
    @contact = Contact.new(params[:contact])
    @contact.request = request
    if @contact.deliver
        
        flash[:notice] = 'Thank you fo your message!'
    
    elsif ScriptError
        flash[:error] = 'Sorry, this message appears to be spam and was not delivered.'

    else
        
        flash[:error] = 'Cannot send message.'
    render :new
    end
  
end
end
