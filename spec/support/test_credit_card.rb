RSpec.configure do |config|
  config.before :each do
    allow_any_instance_of(Mango::PayinCreditCard).to receive(:secure_mode).and_return(false)
  end
end