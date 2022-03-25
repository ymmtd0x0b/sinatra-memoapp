require "sinatra"
require "sinatra/reloader"

class Memo
  attr_accessor :id, :title, :content
  
  def initialize(id, title, content)
    @id = id
    @title = title
    @content = content
  end
end

$memo_list = []
$id = 0

get '/' do
  erb :top
end

get '/new' do
  erb :new
end

post '/new' do
  $id += 1
  title = params[:title]
  content = params[:content]
  memo = Memo.new($id, title, content)
  $memo_list << memo

  redirect '/'
  erb :top
end

get '/show/:id' do
  target_id = params[:id].to_i
  @memo = $memo_list.find { |memo| memo.id == target_id }

  erb :show
end

post '/:id' do
  target_id = params[:id].to_i
  $memo_list.delete_if { |memo| memo.id == target_id }

  redirect '/'
end

get '/edit/:id' do
  target_id = params[:id].to_i
  @memo = $memo_list.find { |memo| memo.id == target_id }

  erb :edit
end

post '/edit/:id' do
  target_id = params[:id].to_i
  target_index = $memo_list.find_index { |memo| memo.id == target_id }
  $memo_list[target_index].title = params[:title]
  $memo_list[target_index].content = params[:content]

  redirect '/'
end
