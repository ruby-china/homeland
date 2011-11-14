require "aws/ses"
ActionMailer::Base.add_delivery_method :ses, AWS::SES::Base,
  :access_key_id     => Setting.aws_access_key_id,
  :secret_access_key => Setting.aws_secret_access_key
