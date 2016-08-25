require 'rails_helper'

describe UserMailer, type: :mailer do
  let(:user) { create :user }

  describe 'welcome' do
  	let(:mail) { UserMailer.welcome(user) }

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t('mail.welcome_subject', app_name: Setting.app_name).to_s)
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq([Setting.email_sender])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match(user.fullname)
    end
  end
end