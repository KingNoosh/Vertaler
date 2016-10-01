require "google/cloud"

@apiKey = ENV['GOOGLE_KEY']

def textToTranslate(text, language)

    gcloud      = Google::Cloud.new
    translate   = gcloud.translate @apiKey
    translation = translate.translate text, to: language

    return translation
end

def languageToLocale(language)
    case language
    when "da"
        return "da-DK"
    when "de"
        return "de-DE"
    when "en"
        return "en-GB"
    when "ca"
        return "ca-ES"
    when "es"
        return "es-ES"
    when "fi"
        return "fi-FI"
    when "fr"
        return "fr-FR"
    when "it"
        return "it-IT"
    when "ja"
        return "ja-JP"
    when "ko"
        return "ko-KR"
    when "nb"
        return "nb-NO"
    when "nl"
        return "nl-NL"
    when "pl"
        return "pl-PL"
    when "pt"
        return "pt-PT"
    when "ru"
        return "ru-RU"
    when "sv"
        return "sv-SE"
    when "zh"
        return "zh-CN"
    else
        return "en-GB"
    end
end

puts languageToLocale("en")
