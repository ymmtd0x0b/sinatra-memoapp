# sinatra版メモアプリ

## インストール

必要なら作業用ディレクトリを作成する

```bash
$ mkdir <ディレクトリ名>
$ cd <作成したディレクトリ名>
```

クローンを作成する

```bash
$ git clone -b memo-app https://github.com/ymmtd0x0b/sinatra-memoapp.git
```

アプリのあるフォルダへ移動する

```bash
$ cd ./sinatra_memoapp
```

アプリの動作に必要なGemをインストールする

```bash
$ bundle install
```

## 事前準備

アプリの起動前にデータベースとテーブルをローカルに準備する(初回のみ)

1. 管理ユーザーでPostgreSQLにログイン

```bash
$ su - postgres
$ psql -U postgres

# このような表示になればOK
postgres=#
```

2. メモアプリ用のデータベースを作成

```bash
postgres=# CREATE DATABASE memo_app

# 作成したデータベースへ切り替え
postgres=# \c memo_app
```

3. テーブルを作成

```bash
memo_app=# CREATE TABLE memo (
memo_app(# id SERIAL PRIMARY KEY NOT NULL,
memo_app(# title VARCHAR(50) NOT NULL,
memo_app(# content VARCHAR(300) NOT NULL);
```

4. ユーザーを作成
アプリ側からデータベースを操作するためのユーザーを作成する

```bash
postgres=# CREATE ROLE memoapp_user LOGIN PASSWORD [password]
```

5.  作成したユーザーにアクセス権を付与( 今回はテーブルとシーケンスにアクセス権が必要 )

```bash
memo_app=# GRANT SELECT, UPDATE, INSERT, DELETE ON memo TO memoapp_user;
GRANT
memo_app=# GRANT SELECT, UPDATE ON SEQUENCE memo_id_seq TO memoapp_user;
GRANT
```

6. `.pgpassファイル`を作成する

```bash
# 一度PostgreSQLを抜けるか、別途ターミナルを立ち上げてホームへ戻る
$ cd ~
$ vim .pgpass

# vim画面
1 # hostname:port:database:username:password
2 localhost:5432:memo_app:memoapp_user:[4.で指定したパスワード]
~
~
~
:wq (保存)
```

7. `.pgassファイル`の権限を変更する
以下のようにすることで自分自身のアカウントでログインしてアプリを起動した場合のみログイン可能になるので、( 自分のアカウントが乗っ取られる以外の )不正なログインを防止できる

```bash
$ chmod 600 .pgpass
```

## 起動

以下のコマンドでアプリを起動する
```bash
$ bundle exec ruby main.rb
```

http://localhost:4567 にアクセスするかブラウザのURLへ直接入力する

[![Image from Gyazo](https://i.gyazo.com/5423eb1afb4f08949a4de170b539575c.png)](https://gyazo.com/5423eb1afb4f08949a4de170b539575c)
