require 'sinatra/sequel'
require 'yaml'

content = File.new("database.yml").read
settings = YAML::load(content)

# database shiz
set :database, "#{settings['adapter']}://#{Dir.pwd}/#{settings['database']}"

migration "create csv table" do
  database.create_table :tyra_banks do
    primary_key :id
    string      :filename
    string      :path
    string      :query
  end
end

# as in model, get it? eh, eh??
class TyraBanks < Sequel::Model; end