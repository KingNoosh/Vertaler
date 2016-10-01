require "sinatra"
require "twilio-ruby"

post '/twiml' do
  Twilio::TwiML::Response.new do |r|
    # Use <Say> to give the caller some instructions
    r.Say 'Welcome to Vertaler, the voice translation service.', voice: 'alice'
    r.Say 'Please tell me what you want to hear and in what language.', voice: 'alice'
    r.Say 'For example, if you want to know how to say Hello in French.', voice: 'alice'
    r.Say 'Say hello in French.', voice: 'alice'

    # Use <Record> to record the caller's message
    r.Record

    # End the call with <Hangup>
    r.Hangup
  end.text
end
