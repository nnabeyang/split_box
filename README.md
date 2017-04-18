『精霊の箱[上](https://www.amazon.co.jp/dp/4130633635)[下](https://www.amazon.co.jp/dp/4130633643)』に登場する「塔文字」の言語処理系のruby実装です。いくつかサンプルも`box`ディレクトリに置いております。

## 実行方法
`git clone`するかダウンロードして、`main.rb`を以下のようにして実行することができます。

### 富者の像と貧者の像
```bash
$./main.rb  box/rich_and_poor.sb "010110 "
```

### 文字列の比較

```bash
./main.rb  box/str_cmp.sb " 101|101 "
```
### 足し算

```bash
./main.rb  box/sum.sb  " 111+010 "
```
### 文字列のコピー 

```bash
./main.rb  box/copy.sb  " 101|   "
```
### 設計図の生成
Graphvizがインストールされていて`dot`コマンドが使えるようになっていることが前提ですが、次のようにすると、`images`が作成され、そこにファイルに対応する設計図がpng形式で作成されます。

```bash
./main.rb -v <filepath1> <filepath2> ...
```

### コードの書き方

`split_box`が認識する言語は、命令(instruction)の列から成ります。1行1命令ですので、命令を追加するときは改行します。

```
<instruction1>
<instruction2>
<instruction3>
...
```

各命令はrubyの正規表現で書くと次のパターンに従っているものとします。

```ruby
instruction_pattern = /#{sprintf "%{from_address}.%{input_char}%{replacement}%{direction_of_pointer}.%{to_address}", from_address: "\d+", input_char: ".", replacement: ".", direction_of_pointer: "(<-|->)", to_address: "\d+"}/
```
