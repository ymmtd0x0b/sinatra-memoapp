# sinatra版メモアプリ

## インストール

必要なら作業用ディレクトリを作成する

``` bash
mkdir <ディレクトリ名>
cd <作成したディレクトリ名>
```

クローンを作成する

``` bash
git clone https://github.com/ymmtd0x0b/sinatra-memoapp.git
```

アプリのあるフォルダへ移動する

``` bash
cd ./sinatra_memoapp
```

アプリの動作に必要なGemをインストールする

``` ruby
bundle install
```

## 事前準備

アプリの起動前にデータベースとテーブルをローカルに準備する(初回のみ)

1. 管理ユーザーでPostgreSQLにログイン

``` bash
su - postgres
psql -U postgres
```

2. メモアプリ用のデータベースを作成

``` sql
CREATE DATABASE memo_app;
\c memo_app
```

3. テーブルを作成

``` sql
CREATE TABLE memo (
id SERIAL PRIMARY KEY NOT NULL,
title VARCHAR(50) NOT NULL,
content VARCHAR(300) NOT NULL);
```

4. ユーザーを作成
アプリ側からデータベースを操作するためのユーザーを作成する

``` sql
CREATE ROLE memoapp_user LOGIN PASSWORD '[password]';
```

5.  作成したユーザーにアクセス権を付与( 今回はテーブルとシーケンスにアクセス権が必要 )

``` sql
GRANT SELECT, UPDATE, INSERT, DELETE ON memo TO memoapp_user;
GRANT SELECT, UPDATE ON SEQUENCE memo_id_seq TO memoapp_user;
```

6. 一度PostgreSQLを抜けるか、別途ターミナルを立ち上げてホームへ戻る

7. テキストエディタにて`.pgpass`を開く(以下、例としてvimを使用)

``` bash
cd ~
vim .pgpass
```

8. `.pgpass`に以下をコピー＆ペーストする

```
localhost:5432:memo_app:memoapp_user:[4.で指定したパスワード]
```

9. `.pgassファイル`の権限を変更する
以下のようにすることで自分自身のアカウントでログインしてアプリを起動した場合のみログイン可能になるので、不正なログインを防止できる

``` bash
chmod 600 .pgpass
```

## 起動

以下のコマンドでアプリを起動する
``` ruby
bundle exec ruby main.rb
```

http://localhost:4567 にアクセスするかブラウザのURLへ直接入力する

[![Image from Gyazo](https://i.gyazo.com/5423eb1afb4f08949a4de170b539575c.png)](https://gyazo.com/5423eb1afb4f08949a4de170b539575c)
