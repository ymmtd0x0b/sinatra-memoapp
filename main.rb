# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'erb'
require 'pg'

get '/' do
  @title = 'top'
  @memos = Memo.all
  erb :top
end

get '/memos' do
  redirect '/'
end

get '/memos/new' do
  @title = 'new'
  erb :new
end

post '/memos' do
  @error = validate(params[:title], params[:content])
  if @error.empty?
    Memo.add(params[:title], params[:content])
    redirect '/'
  else
    @title = 'new'
    @memo = { title: params[:title], content: params[:content] }
    erb :new
  end
end

get '/memos/:id' do
  @title = 'show'
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
  @title = 'edit'
  target_id = params[:id].to_i
  @memo = Memo.find(target_id)
  erb :edit
end

patch '/memos/:id' do
  @error = validate(params[:title], params[:content])
  if @error.empty?
    target_id = params[:id].to_i
    Memo.edit(target_id, params[:title], params[:content])
    redirect '/'
  else
    @title = 'edit'
    @memo = { id: params[:id], title: params[:title], content: params[:content] }
    erb :edit
  end
end

module Memo
  TABLE = 'memo'
  DB_CONNECTION = PG.connect(host: 'localhost', port: 5432, dbname: 'memo_app', user: 'memoapp_user')

  private_constant :TABLE, :DB_CONNECTION
  class << self
    def all
      memos = DB_CONNECTION.exec("SELECT * FROM #{TABLE}")
      memos.map { |memo| memo.transform_keys(&:to_sym) }.sort { |a, b| a[:id].to_i <=> b[:id].to_i }
    end

    def find(target_id)
      memo = DB_CONNECTION.exec("SELECT * FROM #{TABLE} WHERE id = $1::int", [target_id])
      memo.first.transform_keys(&:to_sym)
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

def validate(title, content)
  error = {}
  error[:title] = 'タイトルが長すぎます(50文字以内)' if title.length > 50
  error[:content] = '内容が長すぎます(300文字以内)' if content.length > 300
  error
end
