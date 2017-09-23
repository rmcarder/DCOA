require 'sinatra'
require 'twilio-ruby'

get '/enter' do
  Twilio::TwiML::VoiceResponse.new do |r|
    r.say("
      Welcome to the D.C. Office on Aging transportation hotline.
      We will help you get a ride to where you need to go.
    ")
    r.redirect('/age', method: 'get')
  end.to_s
end

get '/age' do
  Twilio::TwiML::VoiceResponse.new do |r|
    r.say("What is your age?")
    r.gather(action: '/handle-age', method: 'get') do |g|
      g.say('Enter your age using the numbers on your telephone, followed by the pound sign.')
    end
  end.to_s
end

get '/handle-age' do
  redirect '/age' if !params.has_key?('Digits')
  redirect '/disability' if params['Digits'].to_i < 60
  redirect '/medical'
end

get '/disability' do
  Twilio::TwiML::VoiceResponse.new do |r|
    r.say("Do you have a disability?")
    r.gather(:numDigits => '1', :action => '/handle-disability', :method => 'get') do |g|
      g.say('Press 1 for yes.')
      g.say('Press 2 for no.')
    end
  end.to_s
end

get '/handle-disability' do
  redirect '/disability' if !params.has_key?('Digits')
  redirect '/medical' if params['Digits'] == '1'
  Twilio::TwiML::VoiceResponse.new do |r|
    r.say("You must be at least 60 years of age or presently disabled to use this service. Goodbye.")
  end.to_s
end

get '/medical' do
  Twilio::TwiML::VoiceResponse.new do |r|
    r.say("Is this ride for a medical appointment?")
    r.gather(:numDigits => '1', :action => '/handle-medical', :method => 'get') do |g|
      g.say('Press 1 for yes.')
      g.say('Press 2 for no.')
    end
  end.to_s
end

get '/handle-medical' do
  redirect '/medical' if !params.has_key?('Digits')
  redirect '/seabury' if params['Digits'] == '1'
  redirect '/purpose' if params['Digits'] == '2'
end

get '/seabury' do
  Twilio::TwiML::VoiceResponse.new do |r|
    r.say("
      Transferring you to Seabury Connector.
      In the future, you can call Seabury Connector directly at 2 0 2, 7 2 7, 7 7 7 1.
      I will repeat that number now.
      2 0 2, 7 2 7, 7 7 7 1.
      Transferring you now.
    ")
    r.dial do |d|
      d.number('2027277771')
    end
  end.to_s
end

get '/purpose' do
  Twilio::TwiML::VoiceResponse.new do |r|
    r.say("This is the end of the line.")
  end.to_s
end
