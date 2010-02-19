require 'rubygems'
require 'sinatra'
require 'open-uri'
require 'nokogiri'
require 'fastercsv'
require 'database'

before do
    headers "Content-Type" => "text/html; charset=utf-8"
end

helpers do
  def link_to url_fragment
    base = request.script_name
    "<a href='#{base}#{url_fragment}'>Download</a>"
  end
end

get '/' do
  @title = "Welcome to Trilyun"
  erb :form
end

post '/create' do
  # create a new CSV
  @csv = TyraBanks.new(params[:post])
  if @csv.save
    # parse the search
    @@query = params[:post][:query].gsub!(/ /, '+')
    @@filename = params[:post][:filename] + '.csv'
    @@doc = Nokogiri::HTML( open("http://www.google.com/search?num=100&q=#{@@query}"))
    FasterCSV.open( File.join( Dir.pwd, '/public/files', @@filename ), 'w' ) do |file|
      @ctr = 1
      file << ["result_num", "title", "link", "description"]
      @@doc.xpath("//h3/a[@class='l']").each do |link|
        description = @@doc.xpath("//div[@class='s']")[@ctr-1]
        file << [@ctr, link.content, link['href'], description]
        @ctr += 1
      end
    end  
    @csv.filename = params[:post][:filename] + '.csv'
    @csv.path = 'http://localhost:9393/files/' + @csv.filename
  end
  @csv.save
  redirect('/')
end

get '/show' do
  @csvs = database[:tyra_banks].all
  erb :download
end

get '/show/:id' do
  @csvs = database[:tyra_banks].filter(:id => params[:id]).first
  erb :download
end
