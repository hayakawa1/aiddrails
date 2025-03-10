#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'

# 出力ディレクトリの準備
output_dir = 'app/views/legal'
FileUtils.mkdir_p(output_dir) unless Dir.exist?(output_dir)

# 各セクションに分けて処理する関数
def process_section(title, sections, output_file)
  File.open(output_file, 'w') do |file|
    file.puts "<% content_for :title, \"#{title} | AIDD.WORK\" %>"
    file.puts
    file.puts "<div class=\"bg-white shadow-sm rounded-lg p-8 my-8\">"
    file.puts "  <h1 class=\"text-3xl font-bold mb-8 text-center\">#{title}</h1>"
    file.puts
    file.puts "  <div class=\"space-y-8\">"
    
    sections.each do |section|
      file.puts "    <section>"
      file.puts "      <h2 class=\"text-xl font-bold mb-4 border-b pb-2\">#{section['heading']}</h2>"
      
      section['content'].each_with_index do |content, index|
        content_str = content.to_s
        # HTMLのエスケープ処理
        content_str = content_str.gsub(/"/, '\"')
        
        if index == 0
          file.puts "      <p>#{content_str}</p>"
        else
          file.puts "      <p class=\"mt-2\">#{content_str}</p>"
        end
      end
      
      file.puts "    </section>"
      file.puts
    end
    
    file.puts "  </div>"
    file.puts
    file.puts "  <div class=\"mt-8 text-center\">"
    file.puts "    <p class=\"text-sm text-gray-500\">最終更新日: <%= Date.today.strftime('%Y年%m月%d日') %></p>"
    file.puts "  </div>"
    file.puts "</div>"
  end
end

# YAMLファイルを直接読み込み
yaml_path = File.expand_path('legal_pages.yml')
yaml_content = File.read(yaml_path)

# テキスト処理で各セクションを抽出
commerce_yaml = yaml_content.split('title: 利用規約')[0]
commerce_data = YAML.load(commerce_yaml)

terms_yaml = "title: 利用規約" + yaml_content.split('title: 利用規約')[1].split('title: プライバシーポリシー')[0]
terms_data = YAML.load(terms_yaml)

privacy_yaml = "title: プライバシーポリシー" + yaml_content.split('title: プライバシーポリシー')[1]
privacy_data = YAML.load(privacy_yaml)

# 各ファイルを生成
process_section(commerce_data['title'], commerce_data['sections'], File.join(output_dir, "commerce.html.erb"))
puts "生成しました: #{File.join(output_dir, "commerce.html.erb")}"

process_section(terms_data['title'], terms_data['sections'], File.join(output_dir, "terms.html.erb"))
puts "生成しました: #{File.join(output_dir, "terms.html.erb")}"

process_section(privacy_data['title'], privacy_data['sections'], File.join(output_dir, "privacy.html.erb"))
puts "生成しました: #{File.join(output_dir, "privacy.html.erb")}"

puts "YAMLからERBへの変換が完了しました。" 