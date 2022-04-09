# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'erb'
require 'pg'

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
  TABLE = 'memo'
  DB_CONNECTION = PG.connect(host: 'localhost', port: 5432, dbname: 'memo_app', user: 'memoapp_user')

  class << self
    def all
      memo_data = DB_CONNECTION.exec("SELECT * FROM #{TABLE}")
      memo_data.map { |memo| memo.transform_keys(&:to_sym) }
    end

    def find(target_id)
      result = DB_CONNECTION.exec("SELECT * FROM #{TABLE} WHERE id = $1::int", [target_id])
      result.first.transform_keys(&:to_sym)
    end

    def add(title, content)
      DB_CONNECTION.exec("INSERT INTO #{TABLE} (title, content) VALUES ($1::varchar, $2::varchar)", [title, content])
    end

    def delete(target_id)
      DB_CONNECTION.exec("DELETE FROM #{TABLE} WHERE id = $1::int", [target_id])
    end

    def edit(target_id, title, content)
      DB_CONNECTION.exec("UPDATE #{TABLE} SET title = $1::varchar, content = $2::varchar WHERE id = $3::int", [title, content, target_id])
    end
  end
end

def sanitize(input_data)
  ERB::Util.html_escape(input_data)
end
