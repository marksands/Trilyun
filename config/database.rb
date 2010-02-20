require 'sinatra/sequel'
require 'open-uri'
require 'nokogiri'
require 'fastercsv'
require 'nokogiri'
require 'yaml'

content = File.new("config/database.yml").read
settings = YAML::load(content)

# database shiz
set :database, "#{settings['adapter']}://#{Dir.pwd}/config/#{settings['database']}"

migration "create tyra_banks table" do
  database.create_table :tyra_banks do
    primary_key :id
    string      :filename
  end
end

# as in model, get it? eh, eh?? America's next top... forget it.
class TyraBanks < Sequel::Model
  def generate_file query, post
    query = query[:query]
    filename = post[:filename] + '.csv'
    doc = Nokogiri::HTML( open(URI.escape( "http://www.google.com/search?num=100&q=#{query}")))
    # write to file
    FasterCSV.open( File.join( Dir.pwd, '/public/files', filename ), 'w' ) do |file|
      file << ["result_num", "title", "link", "description"]
      doc.xpath("//h3/a[@class='l']").each_with_index do |link, index|
        description = doc.xpath("//div[@class='s']")[index]
        file << [index+1, link.content, link['href'], description]
      end
    end  
  end
end