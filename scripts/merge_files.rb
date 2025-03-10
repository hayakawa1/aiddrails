#!/usr/bin/env ruby
# 実行方法:
# 1. ターミナルで次のコマンドを実行してスクリプトに実行権限を付与する
#    chmod +x scripts/merge_files.rb
# 2. スクリプトを実行する
#    ruby scripts/merge_files.rb
#
# 結果として、project_files.txt というファイルがプロジェクトルートに生成されます。
# このファイルには、プロジェクト固有のERB、YML、RBファイルの内容が含まれています。

require 'find'

# 出力ファイル名
OUTPUT_FILE = 'project_files.txt'

# 対象となる拡張子
TARGET_EXTENSIONS = ['.erb', '.yml', '.yaml', '.rb']

# 無視するディレクトリパターン
IGNORE_DIRS = [
  /^\.git/,           # Gitディレクトリ
  /^node_modules/,    # Node.jsのモジュール
  /^vendor/,          # ベンダーのライブラリ
  /^tmp/,             # 一時ファイル
  /^log/              # ログファイル
]

# 無視するファイルパターン
IGNORE_FILES = [
  /^Gemfile/,         # Gemfile関連
  /^Rakefile/,        # Rakefile
  /^config\.ru/,      # Rack設定ファイル
  /^bin\//,           # バイナリファイル
  /^db\/schema\.rb/,  # DBスキーマ
  /^config\/boot\.rb/,# Boot設定
  /^config\/application\.rb/, # アプリケーション設定
  /^config\/environment\.rb/, # 環境設定
  /^config\/environments\//, # 環境別設定
  /^config\/initializers\//, # 初期化スクリプト
]

# このディレクトリが対象かどうかを判定する
def should_process_dir?(dir)
  relative_dir = dir.sub(Dir.pwd + '/', '')
  !IGNORE_DIRS.any? { |pattern| relative_dir =~ pattern }
end

# このファイルが対象かどうかを判定する
def should_process_file?(file)
  relative_file = file.sub(Dir.pwd + '/', '')
  ext = File.extname(file).downcase
  
  TARGET_EXTENSIONS.include?(ext) && 
    !IGNORE_FILES.any? { |pattern| relative_file =~ pattern }
end

# ファイルの内容を整形して返す
def format_file_content(file)
  content = File.read(file)
  relative_path = file.sub(Dir.pwd + '/', '')
  ext = File.extname(file).downcase
  
  separator = "=" * 80
  header = "#{separator}\n#{relative_path}\n#{separator}\n\n"
  footer = "\n\n"
  
  header + content + footer
end

# メインの処理
begin
  puts "プロジェクトファイルのマージを開始します..."
  
  # 検出したファイルの配列
  files_to_merge = []
  
  # ファイルを検索
  Find.find(Dir.pwd) do |path|
    if FileTest.directory?(path)
      if !should_process_dir?(path)
        Find.prune  # このディレクトリ以下は無視
      end
    elsif FileTest.file?(path) && should_process_file?(path)
      files_to_merge << path
    end
  end
  
  # ソートしてファイルの順序を保証
  files_to_merge.sort!
  
  # 結果を出力
  File.open(OUTPUT_FILE, 'w') do |output|
    # ヘッダー情報
    output.puts "=" * 80
    output.puts "プロジェクトファイル一覧"
    output.puts "作成日時: #{Time.now}"
    output.puts "ファイル数: #{files_to_merge.length}"
    output.puts "=" * 80
    output.puts "\n"
    
    # ファイル一覧を出力
    output.puts "## ファイル一覧"
    files_to_merge.each do |file|
      output.puts "- #{file.sub(Dir.pwd + '/', '')}"
    end
    output.puts "\n"
    
    # 各ファイルの内容を出力
    output.puts "## ファイル内容"
    files_to_merge.each do |file|
      output.puts format_file_content(file)
    end
  end
  
  puts "マージが完了しました。ファイル: #{OUTPUT_FILE}"
  puts "合計 #{files_to_merge.length} 個のファイルがマージされました。"
  
rescue => e
  puts "エラーが発生しました: #{e.message}"
  puts e.backtrace
  exit 1
end 