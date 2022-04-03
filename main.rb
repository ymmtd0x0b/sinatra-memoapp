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
  @memo_list = Memo.all

  erb :top
end

get '/new' do
  erb :new
end

post '/new' do
  Memo.add(params[:title], params[:content])

  redirect '/'
end

get '/show/:id' do
  target_id = params[:id].to_i
  @memo = Memo.find(target_id)

  erb :show
end

delete '/:id' do
  target_id = params[:id].to_i
  Memo.delete(target_id)

  redirect '/'
end

get '/edit/:id' do
  target_id = params[:id].to_i
  @memo = Memo.find(target_id)

  erb :edit
end

patch '/edit/:id' do
  target_id = params[:id].to_i
  Memo.edit(target_id, params[:title], params[:content])

  redirect '/'
end

module Memo
  class << self
    def all
      JSON.parse(File.read(JSON_FILE_NAME))
    end

    def find(target_id)
      memo_list = JSON.parse(File.read(JSON_FILE_NAME))
      memo_list[target_id - 1]
    end

    def add(title, content)
      memo_list = JSON.parse(File.read(JSON_FILE_NAME))
      id = memo_list.length + 1
      title = sanitize(title)
      content = sanitize(content)
      memo_list << { id: id, title: title, content: content }
      File.open(JSON_FILE_NAME, 'w') { |file| file.write(JSON.pretty_generate(memo_list)) }
    end

    def delete(target_id)
      memo_list = JSON.parse(File.read(JSON_FILE_NAME))
      memo_list.delete_at(target_id - 1)
      File.open(JSON_FILE_NAME, 'w') { |file| file.write(JSON.pretty_generate(memo_list)) }
    end

    def edit(target_id, title, content)
      memo_list = JSON.parse(File.read(JSON_FILE_NAME))
      id = target_id - 1
      memo_list[id]['title'] = sanitize(title)
      memo_list[id]['content'] = sanitize(content)
      File.open(JSON_FILE_NAME, 'w') { |file| file.write(JSON.pretty_generate(memo_list)) }
    end

    def sanitize(input_data)
      input_data.to_s.gsub(/([<>"&'])/, ESCAPE_PATTERN)
    end
  end

  private_class_method :sanitize
end
