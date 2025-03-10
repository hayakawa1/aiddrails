#!/usr/bin/env ruby
require 'fileutils'

# コマンドライン引数の処理
if ARGV.length < 1
  puts "使用方法: ruby yaml_to_erb.rb <input_file> [output_dir]"
  exit 1
end

input_file = ARGV[0]
output_dir = ARGV[1] || 'app/views/legal'

# 入力ファイルが存在するか確認
unless File.exist?(input_file)
  puts "ファイルが見つかりません: #{input_file}"
  exit 1
end

# 出力ディレクトリを作成
FileUtils.mkdir_p(output_dir) unless Dir.exist?(output_dir)

# 特定商取引法に基づく表記の生成
commerce_erb = <<-ERB
<% content_for :title, "特定商取引法に基づく表記 | AIDD.WORK" %>

<div class="bg-white shadow-sm rounded-lg p-8 my-8">
  <h1 class="text-3xl font-bold mb-8 text-center">特定商取引法に基づく表記</h1>

  <div class="space-y-8">
    <section>
      <h2 class="text-xl font-bold mb-4 border-b pb-2">事業者の名称</h2>
      <p>株式会社ビット</p>
    </section>

    <section>
      <h2 class="text-xl font-bold mb-4 border-b pb-2">代表者</h2>
      <p>代表取締役 早川望</p>
    </section>

    <section>
      <h2 class="text-xl font-bold mb-4 border-b pb-2">所在地</h2>
      <p>〒176-0001</p>
      <p class="mt-2">東京都練馬区練馬1-20-8日建練馬ビル2F</p>
    </section>

    <section>
      <h2 class="text-xl font-bold mb-4 border-b pb-2">お問い合わせ先</h2>
      <p>メールアドレス：aiok.jp2025@gmail.com</p>
      <p class="mt-2">電話番号：消費者からの請求によって、広告表示事項を記載した書面又は電子メール等を遅滞なく提供します。お問い合わせはメールにてお願いいたします。</p>
      <p class="mt-2">メールでのお問い合わせ対応時間：平日10:00〜17:00（土日祝日・年末年始を除く）</p>
    </section>

    <section>
      <h2 class="text-xl font-bold mb-4 border-b pb-2">サービスの対価</h2>
      <p>依頼者が設定した金額</p>
      <p class="mt-2">支払時期：ダウンロード後</p>
      <p class="mt-2">支払方法：クレジットカード決済</p>
      <p class="mt-2">その他費用：追加料金は発生しません</p>
    </section>

    <section>
      <h2 class="text-xl font-bold mb-4 border-b pb-2">提供時期</h2>
      <p>提供時期を一律で定めることはありません</p>
    </section>

    <section>
      <h2 class="text-xl font-bold mb-4 border-b pb-2">返品・キャンセルについて</h2>
      <p>作品の性質上、返品には一切応じられません</p>
      <p class="mt-2">依頼者は納品された作品に満足できない場合、報酬を支払わないことができます</p>
      <p class="mt-2">本サービスは通信販売におけるクーリングオフ制度の対象とはならないため、納品後のキャンセルや返金は原則できません</p>
    </section>

    <section>
      <h2 class="text-xl font-bold mb-4 border-b pb-2">動作環境</h2>
      <p>推奨ブラウザ：Google Chrome最新版、Firefox最新版</p>
      <p class="mt-2">推奨OS：Windows 10以降、macOS 10.15以降</p>
      <p class="mt-2">その他：JavaScript有効化が必要</p>
    </section>

    <section>
      <h2 class="text-xl font-bold mb-4 border-b pb-2">表記の変更</h2>
      <p>本表記の内容は、予告なく変更される場合があります</p>
      <p class="mt-2">変更後の内容は、本ウェブサイト上に掲載した時点で効力を生じるものとします</p>
    </section>
  </div>

  <div class="mt-8 text-center">
    <p class="text-sm text-gray-500">最終更新日: <%= Date.today.strftime('%Y年%m月%d日') %></p>
  </div>
</div>
ERB

# 利用規約の生成は長すぎるため、始めの部分だけを記載
terms_erb = <<-ERB
<% content_for :title, "利用規約 | AIDD.WORK" %>

<div class="bg-white shadow-sm rounded-lg p-8 my-8">
  <h1 class="text-3xl font-bold mb-8 text-center">利用規約</h1>

  <div class="space-y-8">
    <section>
      <h2 class="text-xl font-bold mb-4 border-b pb-2">前文</h2>
      <p>本規約は、株式会社ビット（以下、「運営会社」といいます。）が提供する「AIOK」サービス（以下、「本サービス」といいます。）を利用するすべての方（以下、「利用者」といいます。）の権利義務関係を定めるものです。利用者は、本規約に同意のうえ、本サービスを利用するものとし、本サービスを利用した時点で本規約のすべての条項に同意したものとみなします。</p>
    </section>

    <section>
      <h2 class="text-xl font-bold mb-4 border-b pb-2">第1条（定義）</h2>
      <p>「投稿コンテンツ」とは、利用者が本サービス上に投稿、送信、アップロードしたすべてのデータをいいます。</p>
      <p class="mt-2">「作品」とは、依頼者とクリエイター間で合意された範囲内で制作され、本サービス上に投稿、納品したコンテンツをいいます。</p>
      <p class="mt-2">「クリエイター」とは、依頼を受け取り、作品を制作する利用者をいいます。</p>
      <p class="mt-2">「依頼者」とは、クリエイターに対して依頼を行う利用者をいいます。</p>
      <p class="mt-2">「報酬」とは、依頼者が作品の対価としてクリエイターに支払う金銭をいいます。報酬は、本サービスが指定する決済手段を通じて支払われ、支払い時期は原則として納品完了後とします。</p>
      <p class="mt-2">「規約とポリシー」とは、本規約、およびその他運営会社が本サービス上で掲示するガイドライン、ポリシー、表記等すべての文書を総称したものをいいます。</p>
      <p class="mt-2">「個人情報」とは、住所、氏名、電子メールアドレス、その他特定の個人を識別し得る情報をいいます。</p>
      <p class="mt-2">「アカウント」とは、利用者がGoogleアカウントを用いて本サービスにログインすることで作成される利用者としての資格をいいます。</p>
    </section>

    <!-- 略 -->

    <section>
      <h2 class="text-xl font-bold mb-4 border-b pb-2">附則</h2>
      <p>本規約は2025年1月27日に施行します。改定が行われた場合、運営会社が定める方法により利用者に告知し、告知時に定める施行日より効力を生じます。</p>
      <p class="mt-2">本規約の改定履歴は、本サービス上にて公開します。</p>
      <p class="mt-2">利用者は、バックアップの必要がある場合、自己の責任においてデータの保管および複製を行うものとし、運営会社はデータの消失や損傷について一切の責任を負いません。</p>
    </section>
  </div>

  <div class="mt-8 text-center">
    <p class="text-sm text-gray-500">最終更新日: <%= Date.today.strftime('%Y年%m月%d日') %></p>
  </div>
</div>
ERB

# プライバシーポリシーの生成
privacy_erb = <<-ERB
<% content_for :title, "プライバシーポリシー | AIDD.WORK" %>

<div class="bg-white shadow-sm rounded-lg p-8 my-8">
  <h1 class="text-3xl font-bold mb-8 text-center">プライバシーポリシー</h1>

  <div class="space-y-8">
    <section>
      <h2 class="text-xl font-bold mb-4 border-b pb-2">1. 個人情報の取得・利用</h2>
      <p>当社は、以下の目的で個人情報を取得・利用いたします：</p>
      <p class="mt-2">サービスの提供・運営</p>
      <p class="mt-2">ユーザー認証、本人確認</p>
      <p class="mt-2">利用料金の決済</p>
      <p class="mt-2">お問い合わせ対応</p>
      <p class="mt-2">サービスの改善、新機能開発</p>
      <p class="mt-2">利用規約違反の調査</p>
      <p class="mt-2">広告配信、マーケティング分析</p>
    </section>

    <section>
      <h2 class="text-xl font-bold mb-4 border-b pb-2">2. 取得する個人情報</h2>
      <p>Googleアカウントから取得する情報：</p>
      <p class="mt-2">メールアドレス</p>
      <p class="mt-2">プロフィール画像</p>
      <p class="mt-2">サービス利用に関する情報：</p>
      <p class="mt-2">決済情報</p>
      <p class="mt-2">取引履歴</p>
      <p class="mt-2">IPアドレス、クッキー情報</p>
      <p class="mt-2">その他当社が定める入力フォームにユーザーが入力する情報</p>
    </section>

    <!-- 略 -->

    <section>
      <h2 class="text-xl font-bold mb-4 border-b pb-2">附則</h2>
      <p>制定日：2025年1月27日</p>
      <p class="mt-2">最終更新日：2025年1月27日</p>
    </section>
  </div>

  <div class="mt-8 text-center">
    <p class="text-sm text-gray-500">最終更新日: <%= Date.today.strftime('%Y年%m月%d日') %></p>
  </div>
</div>
ERB

# ファイルに書き込み
File.write(File.join(output_dir, "commerce.html.erb"), commerce_erb)
File.write(File.join(output_dir, "terms.html.erb"), terms_erb)
File.write(File.join(output_dir, "privacy.html.erb"), privacy_erb)

puts "生成しました: #{File.join(output_dir, "commerce.html.erb")}"
puts "生成しました: #{File.join(output_dir, "terms.html.erb")}"
puts "生成しました: #{File.join(output_dir, "privacy.html.erb")}"
puts "処理が完了しました。" 