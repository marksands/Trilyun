require 'rubygems'
require 'sinatra'
require 'config/database'

before do
    headers "Content-Type" => "text/html; charset=utf-8"
end

helpers do
  def link_to url, title='Download'
    "<a href='#{url}'>#{title}</a>"
  end
end

get '/' do
  @title = "Welcome to Trilyun"
  erb :form
end

post '/create' do
  @csv = TyraBanks.new(params[:tyrabanks])
  @csv.generate_file(params[:post], params[:tyrabanks])
  if @csv.save
    redirect('/download') 
  else
    redirect('/')
  end
end

get '/download' do
  @csvs = database[:tyra_banks].all
  erb :download
end
