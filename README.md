# sinatra版メモアプリ

## インストール

必要なら作業用ディレクトリを作成する

```bash
$ mkdir <ディレクトリ名>
$ cd <作成したディレクトリ名>
```

クローンを作成する

```bash
$ git pull https://github.com/ymmtd0x0b/sinatra-memoapp.git
```

アプリのあるフォルダへ移動する

```bash
$ cd ./sinatra_memoapp
```

アプリの動作に必要なGemをインストールする

```bash
$ bundle install
```

## 起動

`memo_appフォルダ`へ移動する

```bash
$ cd memo_app
```

以下のコマンドでアプリを起動する
```bash
$ bundle exec ruby main.rb -p 4567
```

http://localhost:4567 にアクセスするかブラウザのURLへ直接入力する

[![Image from Gyazo](https://i.gyazo.com/5423eb1afb4f08949a4de170b539575c.png)](https://gyazo.com/5423eb1afb4f08949a4de170b539575c)
