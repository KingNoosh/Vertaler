require "sinatra"
require "twilio-ruby"
require "google/cloud"
require "unicode"
require "unidecoder"

accountSid = ENV['TWILLIO_SID']
authToken  = ENV['TWILLIO_AUTH']
apiKey     = ENV['GOOGLE_TRANSLATE']

gcloud  = Google::Cloud.new
twillio = Twilio::REST::Client.new accountSid, authToken

hashLanguages = {
  'Afrikaans'           => 'af',
  'Albanian'            => 'sq',
  'Arabic'              => 'ar',
  'Armenian'            => 'hy',
  'Azerbaijani'         => 'az',
  'Basque'              => 'eu',
  'Belarusian'          => 'be',
  'Bengali'             => 'bn',
  'Bosnian'             => 'bs',
  'Bulgarian'           => 'bg',
  'Catalan'             => 'ca',
  'Cebuano'             => 'ceb',
  'Chichewa'            => 'ny',
  'Chinese Simplified'  => 'zh-CN',
  'Chinese Traditional' => 'zh-TW',
  'Croatian'            => 'hr',
  'Czech'               => 'cs',
  'Danish'              => 'da',
  'Dutch'               => 'nl',
  'English'             => 'en',
  'Esperanto'           => 'eo',
  'Estonian'            => 'et',
  'Filipino'            => 'tl',
  'Finnish'             => 'fi',
  'French'              => 'fr',
  'Galician'            => 'gl',
  'Georgian'            => 'ka',
  'German'              => 'de',
  'Greek'               => 'el',
  'Gujarati'            => 'gu',
  'Haitian Creole'      => 'ht',
  'Hausa'               => 'ha',
  'Hebrew'              => 'iw',
  'Hindi'               => 'hi',
  'Hmong'               => 'hmn',
  'Hungarian'           => 'hu',
  'Icelandic'           => 'is',
  'Igbo'                => 'ig',
  'Indonesian'          => 'id',
  'Irish'               => 'ga',
  'Italian'             => 'it',
  'Japanese'            => 'ja',
  'Javanese'            => 'jw',
  'Kannada'             => 'kn',
  'Kazakh'              => 'kk',
  'Khmer'               => 'km',
  'Korean'              => 'ko',
  'Lao'                 => 'lo',
  'Latin'               => 'la',
  'Latvian'             => 'lv',
  'Lithuanian'          => 'lt',
  'Macedonian'          => 'mk',
  'Malagasy'            => 'mg',
  'Malay'               => 'ms',
  'Malayalam'           => 'ml',
  'Maltese'             => 'mt',
  'Maori'               => 'mi',
  'Marathi'             => 'mr',
  'Mongolian'           => 'mn',
  'Myanmar (Burmese)'   => 'my',
  'Nepali'              => 'ne',
  'Norwegian'           => 'no',
  'Persian'             => 'fa',
  'Polish'              => 'pl',
  'Portuguese'          => 'pt',
  'Punjabi'             => 'ma',
  'Romanian'            => 'ro',
  'Russian'             => 'ru',
  'Serbian'             => 'sr',
  'Sesotho'             => 'st',
  'Sinhala'             => 'si',
  'Slovak'              => 'sk',
  'Slovenian'           => 'sl',
  'Somali'              => 'so',
  'Spanish'             => 'es',
  'Sudanese'            => 'su',
  'Swahili'             => 'sw',
  'Swedish'             => 'sv',
  'Tajik'               => 'tg',
  'Tamil'               => 'ta',
  'Telugu'              => 'te',
  'Thai'                => 'th',
  'Turkish'             => 'tr',
  'Ukrainian'           => 'uk',
  'Urdu'                => 'ur',
  'Uzbek'               => 'uz',
  'Vietnamese'          => 'vi',
  'Welsh'               => 'cy',
  'Yiddish'             => 'yi',
  'Yoruba'              => 'yo',
  'Zulu'                => 'zu'
}

hashLocales = {
  'da' => "da-DK",
  'de' => "de-DE",
  'en' => "en-GB",
  'ca' => "ca-ES",
  'es' => "es-ES",
  'fi' => "fi-FI",
  'fr' => "fr-FR",
  'it' => "it-IT",
  'ja' => "ja-JP",
  'ko' => "ko-KR",
  'nb' => "nb-NO",
  'nl' => "nl-NL",
  'pl' => "pl-PL",
  'pt' => "pt-PT",
  'ru' => "ru-RU",
  'sv' => "sv-SE",
  'zh' => "zh-CN"
}

post '/' do
  sender      = params['From'],
  receiver    = params['To']
  body        = params['Body']
  arrBody     = /(.*) in (.*)/.match(body)
  phrase      = arrBody[1]
  language    = arrBody[2]
  country     = hashLanguages[language]
  locale      = hashLocales[country]
  translate   = gcloud.translate apiKey
  translation = translate.translate phrase, to: country
  if locale.nil?
    twillio.account.messages.create({
      :from => receiver,
      :to => sender,
      :body => "The phrase '#{phrase}' in '#{language}' is '#{translation.text}'",
    })
  else
    ascii_str = translation.text.to_ascii
    puts ascii_str
    ascii_str = ascii_str.gsub! ' ', '%20'
    phrase    = phrase.gsub! ' ', '%20'
    call = twillio.account.calls.create(
      :url  => "http://0cdef1d3.ngrok.io/voice?Text=#{ascii_str}&Phrase=#{phrase}&Country=#{translation.to}&Locale=#{locale}&Language=#{language}",
      :to   => sender,
      :from => receiver
    )
  end
  Twilio::TwiML::Response.new do |r|
    r.Message "Welcome to Vertaler, the SMS translation service. You've just asked me to translate the phrase '#{phrase}' into '#{language}'."
  end.text
end
post '/voice' do
  translation = params['Text']
  country     = params['Country']
  locale      = params['Locale']
  phrase      = params['Phrase']
  language    = params['Language']

  Twilio::TwiML::Response.new do |r|
    r.Say "The phrase #{phrase} in #{language} is", voice: 'alice'
    r.Say translation, voice: 'alice', language: locale
    r.Say "Good bye!"
  end.text
end
