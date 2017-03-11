class CustomDeviseMailer < Devise::Mailer
  helper :application
  include Devise::Controllers::UrlHelpers
  default template_path: 'devise/mailer'

  def confirmation_instructions(record, token, opts={})
    template = '6fa5dbfc-ccf8-4236-ae4b-d9d96e84a2f6'
    # insert here customizations
    opts= {"X-SMTPAPI" => {"filters" => {
              "templates" => {
                "settings" => {
                  "enable" => 1, "template_id" =>template}
                }
              }
            }.to_json
    }
    super
  end
  def reset_password_instructions(record, token, opts={})
    opts =  {"X-SMTPAPI" =>{"filters" => {
              "templates" => {
                "settings" => {
                  "enable" => 1, "template_id" => "208ffcb4-5129-4111-8aa2-1353abde1bc2"}
                }
              }
            }.to_json
    }
    super
  end
end