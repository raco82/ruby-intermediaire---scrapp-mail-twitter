require 'rubygems'
require 'twitter'
require 'google_drive'

# recuperation de la liste des communes via le google drive
def get_city
  # initialisation du spreadsheet
  session = GoogleDrive::Session.from_config('../config.json')
  ws = session.spreadsheet_by_key('ID DU TABLEUR DANS GOOGLE DRIVE').worksheets[0]
  # initialisation des données
  i = 2
  city = ws[i, 1]
  # boucle pour passer sur chaque ligne du spreadsheet
  until ws[i, 1] == ws[129, 1]
    tweetCity(city)
    i += 1
  end
end

# methode pour follow sur Twitter
def tweetCity(city)
  # quelques lignes qui enregistrent les clés d'APIs
  @client = Twitter::REST::Client.new do |config|
    config.consumer_key        = ''
    config.consumer_secret     = ''
    config.access_token        = ''
    config.access_token_secret = ''
  end
  # liste des journalistes
  @city = '@{city}'
  # on spam à la fraîche
  def tweetCity
    @city.each { |city| @client.update("Hello #{city},vous connaissez https://putaclic.aixit.fr ?") }
    # sleep
    sleep 120
  end
  tweetCity

  # initialisation des identifiants
  client = Twitter::REST::Client.new do |config|
    config.consumer_key        = 'JSON'
    config.consumer_secret     = 'JSON'
    config.access_token        = 'JSON'
    config.access_token_secret = 'JSON'
  end

  # FAIL malheureusement nous n'avons pas reussi ...
  info = client.user_search(city)
  puts city
  info.follow(city)
end

get_city
