require 'rubygems'
require 'open-uri'
require 'google_drive'
require 'gmail'

def get_worksheet(worksheet_key)
  # auth via config.json
  session = GoogleDrive::Session.from_config('../config.json')
  # clé ID du spreadsheet
  session.spreadsheet_by_key(worksheet_key).worksheets[0]
end

# On parse
def go_through_all_the_lines(worksheet_key)
  data = []
  worksheet = get_worksheet(worksheet_key)
  worksheet.rows.each do |row|
    data << row[1].gsub(/[[:space:]]/, '')
  end
  data
end

# on récupère ce qu'il y a dans le .html pour l'envoie de mail
def get_email_html(file_path)
  data = ''
  f = File.open(file_path, 'r')
  f.each_line do |line|
    data += line
  end
  data
end

# les images
def get_email_image(image_path)
  image_path
end

# Sauvegarde à la fin d'un récap dans un fichier txt
def save_to_file(emails)
  File.open('email_sent_list.txt', 'w') do |file|
    emails.each do |email|
      file.write("Vous avez bien envoyé un mail à #{email}\n")
    end
  end
end

# Send email 6 parameters worksheet_key, html_path, image_path are hard coded
def send_gmail_to_listing(username, password, subject_text, worksheet_key, html_path, image_path)
  # Connect to gmail and puts
  # username and password are parameters you will input as argument on command line
  gmail = Gmail.connect(username, password)
  puts 'Gmail login'

  # Call the go_through_all_the_lines function wich returns all the emails in an array
  email_listing = go_through_all_the_lines(worksheet_key)

  # Iterate through all the emails
  email_listing.each do |email|
    # For each email send mail to email
    gmail.deliver do
      to email
      # subject_text variable is a parameter you will input as argument on command line
      subject subject_text
      # Send the content in the email as html
      html_part do
        content_type 'text/html; charset=UTF-8'
        # Call the get_email_html function to get the body content
        body get_email_html(html_path)
      end
      # Call the get_email_image function to add an image to the email
      add_file get_email_image(image_path)
    end
    # Puts a message on console when the email is successfully sent
    puts "Email envoyé avec succes à #{email}"
  end
  # Call the save_to_file function to save the output in a text file
  save_to_file(email_listing)
  # Log out of gmail and puts
  gmail.logout
  puts 'Gmail logout, le script a terminé'
end

# Get user input for the username argument
puts 'Entrez votre compte Google email'
username = gets.chomp.to_s

# Get user input for the password argument
puts 'Entrez votre mot de passe'
password = gets.chomp.to_s

# Get user input for the email subject argument
puts "Entrez maintenant l'objet/sujet de votre email"
subject = gets.chomp.to_s

# Call the send_email_to_listing function with all arguments to excute the script
send_gmail_to_listing(username, password, subject, 'ID spreadsheet', 'email_template.html')
