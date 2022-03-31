# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'

JSON_FILE_NAME = 'memo_data.json'
ESCAPE_PATTERN = {
  '<' => '&lt;',
  '>' => '&gt;',
  '"' => '&quot;',
  '&' => '&amp;',
  '\'' => '&#39;'
}.freeze

get '/' do
  @memo_list = json_data['memo_list']

  erb :top
end

get '/new' do
  erb :new
end

post '/new' do
  memo_data = json_data
  memo_data['id'] += 1
  new_memo = { id: memo_data['id'],
               title: sanitize(params[:title]),
               content: sanitize(params[:content]) }
  memo_data['memo_list'] << new_memo
  to_json_file(memo_data)

  redirect '/'
end

get '/show/:id' do
  target_id = params[:id].to_i
  @memo = json_data['memo_list'].find { |memo| memo['id'] == target_id }

  erb :show
end

delete '/:id' do
  memo_data = json_data
  target_id = params[:id].to_i
  memo_data['memo_list'].delete_if { |memo| memo['id'] == target_id }
  to_json_file(memo_data)

  redirect '/'
end

get '/edit/:id' do
  target_id = params[:id].to_i
  @memo = json_data['memo_list'].find { |memo| memo['id'] == target_id }

  erb :edit
end

patch '/edit/:id' do
  target_id = params[:id].to_i
  memo_data = json_data
  index = memo_data['memo_list'].find_index { |memo| memo['id'] == target_id }
  memo_data['memo_list'][index]['title'] = sanitize(params[:title])
  memo_data['memo_list'][index]['content'] = sanitize(params[:content])
  to_json_file(memo_data)

  redirect '/'
end

def json_data
  JSON.parse(File.read(JSON_FILE_NAME))
end

def to_json_file(data)
  File.open(JSON_FILE_NAME, 'w') { |file| file.write(JSON.pretty_generate(data)) }
end

def sanitize(input_data)
  input_data.to_s.gsub(/([<>"&'])/, ESCAPE_PATTERN)
end
