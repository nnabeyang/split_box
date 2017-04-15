[nnabeyng/split_box](https://github.com/nnabeyang/split_box)に『[精霊の箱](https://www.amazon.co.jp/dp/4130633635)』に登場する「塔文字」の言語処理系を置きました。いくつかサンプルも`resources`ディレクトリに置いております。

##実行方法
`git clone`するかダウンロードして、rubyをインストールしていれば、`main.rb`を以下のようにして実行することができます。

### 富者の像と貧者の像
```bash
$./main.rb  resources/rich_and_poor.sb "010110 "
```

### 文字列の比較

```bash
./main.rb  resources/str_cmp.sb " 101-101 "
```
### 足し算

```bash
./main.rb  resources/sum.sb  " 111+010 "
```
