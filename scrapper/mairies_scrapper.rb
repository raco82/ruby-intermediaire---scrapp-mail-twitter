require 'google_drive'
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'pry'

# On envoie NOKO en mode css pour choper les infos mairies
def mairie(lien_mairie)
  mairie_page = Nokogiri::HTML(open(lien_mairie))
  mairie_info = mairie_page.css('div[1]/main/section[1]/div/div/div/h1').text.split(' - ')
  name = mairie_info[0]
  dept = mairie_page.css('/html/body/div/main/section[4]/div/table/tbody/tr[1]/td[2]').text
  email = mairie_page.css('div[1]/main/section[2]/div/table/tbody/tr[4]/td[2]').text
  h = Hash[name: name, email: email, dept: dept]
  h
end

# On balance tout dans un spreadsheet sur google drive
def send_to_spreadsheet(hash_array)
  session = GoogleDrive::Session.from_config('../config.json')
  ws = session.spreadsheet_by_key('ID DU spreadsheet').worksheets[0]
  ws[1, 1] = 'Mairie'
  ws[1, 2] = 'Email'
  ws[1, 3] = 'Département'

  i = 2 # a premiere ligne contient les titres
  hash_array.each do |x|
    ws[i, 1] = x[:name]
    ws[i, 2] = x[:email]
    ws[i, 3] = x[:dept]
    ws.save
    i += 1
  end
end

def scan_list_mairie(lien)
  url_origin = 'http://annuaire-des-mairies.com/'
  list_mairie = []
  page_origin = Nokogiri::HTML(open(lien))
  mairie_link = page_origin.css('a.lientxt')
  mairie_link.each do |x|
    link = x['href']
    link_to_mairie = URI.join(url_origin, link).to_s
    list_mairie.push(mairie(link_to_mairie))
  end
  list_mairie
end

def perform
  url_origin = 'http://annuaire-des-mairies.com/bouches-du-rhone.html'

  send_to_spreadsheet(scan_list_mairie(url_origin))
end

perform
