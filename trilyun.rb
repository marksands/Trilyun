require 'rubygems'
require 'sinatra'
require 'open-uri'
require 'nokogiri'
require 'fastercsv'
require 'config/database'

before do
    headers "Content-Type" => "text/html; charset=utf-8"
end

helpers do
  def link_to url, title='Download'
    base = request.script_name
    "<a href='#{base}#{url}'>#{title}</a>"
  end
end

get '/' do
  @title = "Welcome to Trilyun"
  erb :form
end

post '/create' do
  # create a new CSV
  @csv = TyraBanks.new(params[:tyrabanks])
  if @csv.save
    # parse the search
    @@query = params[:post][:query]
    @@filename = params[:tyrabanks][:filename] + '.csv'
    @@url = URI.escape( "http://www.google.com/search?num=100&q=#{@@query}")
    @@doc = Nokogiri::HTML( open(@@url) )
    FasterCSV.open( File.join( Dir.pwd, '/public/files', @@filename ), 'w' ) do |file|
      file << ["result_num", "title", "link", "description"]
      @@doc.xpath("//h3/a[@class='l']").each_with_index do |link, index|
        description = @@doc.xpath("//div[@class='s']")[index]
        file << [index+1, link.content, link['href'], description]
      end
    end  
    @csv.filename = @@filename
    @csv.path = 'http://localhost:9393/files/' + @csv.filename
  end
  @csv.save
  redirect('/')
end

get '/download' do
  @csvs = database[:tyra_banks].all
  erb :download
end

