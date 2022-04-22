# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'erb'
require 'pg'

get '/' do
  @title = 'Top'
  @memos = DataBase.all
  erb :top
end

get '/memos' do
  redirect '/'
end

get '/memos/new' do
  @title = 'New'
  @memo = Memo.new
  erb :new
end

post '/memos' do
  @memo = Memo.new(title: params[:title], content: params[:content])
  if @memo.save
    redirect '/'
  else
    @title = 'New'
    erb :new
  end
end

get '/memos/:id' do
  @title = 'Show'
  @memo = DataBase.find(params[:id].to_i)
  erb :show
end

delete '/memos/:id' do
  DataBase.delete(params[:id].to_i)
  redirect '/'
end

get '/memos/:id/edit' do
  @title = 'Edit'
  @memo = DataBase.find(params[:id].to_i)
  erb :edit
end

patch '/memos/:id' do
  @memo = Memo.new(id: params[:id], title: params[:title], content: params[:content])
  if @memo.edit_save
    redirect '/'
  else
    @title = 'Edit'
    erb :edit
  end
end

class Memo
  attr_reader :id, :errors

  def initialize(id: nil, title: nil, content: nil)
    @id = id
    @title = title
    @content = content
    @errors = []
  end

  def title
    sanitize(@title)
  end

  def content
    sanitize(@content)
  end

  def save
    validate
    DataBase.add(@title, @content) if @errors.empty?
  end

  def edit_save
    validate
    DataBase.edit(@id, @title, @content) if @errors.empty?
  end

  private

  def sanitize(text)
    ERB::Util.html_escape(text)
  end

  def validate
    @errors << 'タイトルが長すぎます(50文字以内)' if @title.length > 50
    @errors << '内容が長すぎます(300文字以内)' if @content.length > 300
    @errors
  end
end

module DataBase
  TABLE = 'memo'
  DB_CONNECTION = PG.connect(host: 'localhost', port: 5432, dbname: 'memo_app', user: 'memoapp_user')
  private_constant :TABLE, :DB_CONNECTION

  class << self
    def all
      memos = DB_CONNECTION.exec("SELECT * FROM #{TABLE} ORDER BY id")
      memos = memos.map { |memo| memo.transform_keys(&:to_sym) }
      memos.map { |memo| Memo.new(id: memo[:id], title: memo[:title], content: memo[:content]) }
    end

    def find(target_id)
      memo = DB_CONNECTION.exec("SELECT * FROM #{TABLE} WHERE id = $1::int", [target_id])
      memo = memo.first.transform_keys(&:to_sym)
      Memo.new(id: memo[:id], title: memo[:title], content: memo[:content])
    end

    def add(title, content)
      DB_CONNECTION.exec("INSERT INTO #{TABLE} (title, content) VALUES ($1::varchar, $2::varchar)", [title, content])
    end

    def edit(target_id, title, content)
      DB_CONNECTION.exec("UPDATE #{TABLE} SET title = $1::varchar, content = $2::varchar WHERE id = $3::int", [title, content, target_id])
    end

    def delete(target_id)
      DB_CONNECTION.exec("DELETE FROM #{TABLE} WHERE id = $1::int", [target_id])
    end
  end
end
