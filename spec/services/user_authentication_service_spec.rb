require 'rails_helper'

describe UserAuthenticationService do
  subject { described_class }

  include Capybara::Email::DSL

  let!(:user) { create :user, email: 'valid_email@example.com' }

  context 'invoked to mail login token' do
    scenario 'user with given email does not exist' do
      response = subject.mail_login_token('random@example.com', 'some_referer')

      # it returns user not found error
      expect(response[:success]).to be_falsey
      expect(response[:message]).to eq('Could not find user with given email.')
    end

    scenario 'user with given email exists' do
      old_token = user.login_token
      response = subject.mail_login_token('valid_email@example.com', 'www.example.com')

      expect(response[:success]).to be_truthy
      expect(response[:message]).to eq('Login token successfully emailed.')

      # it should have generated a new token
      user.reload
      expect(user.login_token).to_not eq(old_token)

      # it successfully emails login link with token and referer
      open_email('valid_email@example.com')
      expect(current_email.subject).to eq('Log in to SV.CO')
      expect(current_email.body).to include('http://localhost:3000/authenticate?')
      expect(current_email.body).to include('referer=www.example.com')
      expect(current_email.body).to include("token=#{user.login_token}")
    end
  end

  context 'invoked to authenticate a token' do
    scenario 'token is invalid' do
      response = subject.authenticate_token('some_token')

      # it returns authentication failure
      expect(response[:success]).to be_falsey
      expect(response[:message]).to eq('User authentication failed.')
    end

    scenario 'token is valid' do
      response = subject.authenticate_token(user.login_token)

      # it returns authentication success
      expect(response[:success]).to be_truthy
      expect(response[:message]).to eq('User authenticated successfully.')

      # it should have cleared the token
      user.reload
      expect(user.login_token).to eq(nil)
    end
  end
end
