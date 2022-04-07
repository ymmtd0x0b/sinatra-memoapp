# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'erb'
require 'json'
include ERB::Util

get '/' do
  @memo_list = Memo.all

  erb :top
end

get '/memos' do
  erb :template_memo
end

post '/memos' do
  Memo.add(params[:title], params[:content])

  redirect '/'
end

get '/memos/:id' do
  target_id = params[:id].to_i
  @memo = Memo.find(target_id)

  erb :show_memo
end

delete '/memos/:id' do
  target_id = params[:id].to_i
  Memo.delete(target_id)

  redirect '/'
end

get '/memos/edit/:id' do
  target_id = params[:id].to_i
  @memo = Memo.find(target_id)

  erb :edit_memo
end

patch '/memos/:id' do
  target_id = params[:id].to_i
  Memo.edit(target_id, params[:title], params[:content])

  redirect '/'
end

module Memo
  JSON_FILE_NAME = 'memo_data.json'

  class << self
    def all
      database = JSON.parse(File.read(JSON_FILE_NAME))
      database['memo_list']
    end

    def find(target_id)
      database = JSON.parse(File.read(JSON_FILE_NAME))
      database['memo_list'].find { |memo| memo['id'] == target_id }
    end

    def add(title, content)
      database = JSON.parse(File.read(JSON_FILE_NAME))
      id = database['id_counter'] += 1
      title = sanitize(title)
      content = sanitize(content)
      database['memo_list'] << { id: id, title: title, content: content }
      File.open(JSON_FILE_NAME, 'w') { |file| file.write(JSON.pretty_generate(database)) }
    end

    def delete(target_id)
      database = JSON.parse(File.read(JSON_FILE_NAME))
      database['memo_list'].delete_if { |memo| memo['id'] == target_id }
      File.open(JSON_FILE_NAME, 'w') { |file| file.write(JSON.pretty_generate(database)) }
    end

    def edit(target_id, title, content)
      database = JSON.parse(File.read(JSON_FILE_NAME))
      index = database['memo_list'].find_index { |memo| memo['id'] == target_id }
      database['memo_list'][index]['title'] = sanitize(title)
      database['memo_list'][index]['content'] = sanitize(content)
      File.open(JSON_FILE_NAME, 'w') { |file| file.write(JSON.pretty_generate(database)) }
    end

    def sanitize(input_data)
      html_escape(input_data)
    end
  end

  private_class_method :sanitize
end
