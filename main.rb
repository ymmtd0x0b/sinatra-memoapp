# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'erb'
require 'json'

get '/' do
  @memo_list = Memo.all

  erb :top
end

get '/memos' do
  redirect '/'
end

get '/memos/new' do
  erb :new
end

post '/memos' do
  Memo.add(params[:title], params[:content])

  redirect '/'
end

get '/memos/:id' do
  target_id = params[:id].to_i
  @memo = Memo.find(target_id)

  erb :show
end

delete '/memos/:id' do
  target_id = params[:id].to_i
  Memo.delete(target_id)

  redirect '/'
end

get '/memos/:id/edit' do
  target_id = params[:id].to_i
  @memo = Memo.find(target_id)

  erb :edit
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
      memo_data = JSON.parse(File.read(JSON_FILE_NAME), symbolize_names: true)
      memo_data[:memo_list]
    end

    def find(target_id)
      memo_data = JSON.parse(File.read(JSON_FILE_NAME), symbolize_names: true)
      memo_data[:memo_list].find { |memo| memo[:id] == target_id }
    end

    def add(title, content)
      memo_data = JSON.parse(File.read(JSON_FILE_NAME), symbolize_names: true)
      id = memo_data[:id_counter] += 1
      memo_data[:memo_list] << { id: id, title: title, content: content }
      File.open(JSON_FILE_NAME, 'w') { |file| file.write(JSON.pretty_generate(memo_data)) }
    end

    def delete(target_id)
      memo_data = JSON.parse(File.read(JSON_FILE_NAME), symbolize_names: true)
      memo_data[:memo_list].delete_if { |memo| memo[:id] == target_id }
      File.open(JSON_FILE_NAME, 'w') { |file| file.write(JSON.pretty_generate(memo_data)) }
    end

    def edit(target_id, title, content)
      memo_data = JSON.parse(File.read(JSON_FILE_NAME), symbolize_names: true)
      index = memo_data[:memo_list].find_index { |memo| memo[:id] == target_id }
      memo_data[:memo_list][index][:title] = title
      memo_data[:memo_list][index][:content] = content
      File.open(JSON_FILE_NAME, 'w') { |file| file.write(JSON.pretty_generate(memo_data)) }
    end
  end
end

def sanitize(input_data)
  ERB::Util.html_escape(input_data)
end
