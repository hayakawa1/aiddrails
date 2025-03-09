class Company::InvoicesController < ApplicationController
  before_action :require_login
  before_action :ensure_company_user
  before_action :set_invoice, only: [:show, :mark_as_paid, :download_pdf]
  layout 'company/application'
  
  def index
    @invoices = current_user.invoices_as_company.includes(:individual_user, :job).order(occurred_at: :desc)
  end

  def show
  end
  
  def mark_as_paid
    if @invoice.update(paid: true)
      flash[:notice] = "請求を支払い済みに設定しました"
    else
      flash[:alert] = "ステータスの更新に失敗しました"
    end
    redirect_to company_invoice_path(@invoice)
  end
  
  def download_pdf
    # 請求書のPDFを生成
    pdf_data = generate_invoice_pdf(@invoice)
    
    # ダウンロード用のレスポンス
    send_data pdf_data, 
              filename: "invoice_#{@invoice.id}.pdf", 
              type: 'application/pdf', 
              disposition: 'attachment'
  end
  
  private
  
  def set_invoice
    @invoice = current_user.invoices_as_company.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "請求情報が見つかりません"
    redirect_to company_invoices_path
  end
  
  def ensure_company_user
    unless current_user.user_type == "法人"
      flash[:alert] = "法人ユーザーのみアクセス可能です"
      redirect_to root_path
    end
  end
  
  def generate_invoice_pdf(invoice)
    require 'prawn'
    
    # A4サイズでPDFを作成
    pdf = Prawn::Document.new(page_size: 'A4', margin: [50, 50, 50, 50])
    
    # フォントの設定
    pdf.font_families.update(
      "IpaGothic" => { normal: "#{Rails.root}/app/assets/fonts/ipaexg.ttf" }
    ) rescue nil
    
    pdf.font("IpaGothic") rescue nil
    
    # ヘッダー部分
    pdf.text "請求書", size: 24, style: :bold, align: :center
    pdf.move_down 10
    pdf.text "Invoice", size: 12, style: :italic, align: :center, color: "666666"
    pdf.move_down 20
    
    # 日付と請求番号
    pdf.text "請求番号: #{invoice.id}", size: 12
    pdf.text "発行日: #{invoice.occurred_at.strftime('%Y年%m月%d日')}", size: 12
    pdf.text "支払期限: #{(invoice.occurred_at + 30.days).strftime('%Y年%m月%d日')}", size: 12, color: "cc0000"
    pdf.move_down 20
    
    # 請求先情報（枠で囲む）
    pdf.stroke_rectangle [0, pdf.cursor], 250, 80
    pdf.bounding_box([10, pdf.cursor - 10], width: 230, height: 60) do
      pdf.text "請求先:", size: 14, style: :bold
      pdf.text "#{invoice.company_user.company_profile.company_name} 御中", size: 12
      pdf.text "〒#{invoice.company_user.company_profile.postal_code rescue '000-0000'}", size: 10 if invoice.company_user.company_profile.respond_to?(:postal_code)
      pdf.text "#{invoice.company_user.company_profile.address rescue '住所未設定'}", size: 10 if invoice.company_user.company_profile.respond_to?(:address)
    end
    
    # 請求元情報（右側に配置）
    pdf.bounding_box([300, pdf.cursor + 80], width: 230, height: 80) do
      pdf.text "請求元:", size: 14, style: :bold
      pdf.text "AIDD株式会社", size: 12
      pdf.text "〒100-0001", size: 10
      pdf.text "東京都千代田区1-1-1", size: 10
      pdf.text "TEL: 03-1234-5678", size: 10
      pdf.text "Email: billing@aidd.example.com", size: 10
      pdf.text "担当: 請求担当", size: 10
    end
    
    pdf.move_down 30
    
    # 支払状況
    status_text = invoice.paid ? "支払済" : "未払い"
    status_color = invoice.paid ? "009900" : "cc0000"
    pdf.text "支払状況: ", size: 12, inline_format: true
    pdf.text_box status_text, size: 14, style: :bold, at: [80, pdf.cursor + 12], width: 100, color: status_color
    pdf.move_down 20
    
    # 請求金額（目立たせる）
    pdf.fill_color "f0f0f0"
    pdf.fill_rectangle [0, pdf.cursor], 510, 40
    pdf.fill_color "000000"
    pdf.bounding_box([10, pdf.cursor - 10], width: 490, height: 30) do
      pdf.text "請求金額: #{invoice.amount.to_s(:delimited)}円（税込）", size: 16, style: :bold
    end
    pdf.move_down 40
    
    # 請求内容テーブル
    items = [
      ["項目", "詳細", "金額"],
      ["マッチング手数料", "#{invoice.job.title} × #{invoice.individual_user.individual_profile&.display_name || invoice.individual_user.user_id}", "#{invoice.amount.to_s(:delimited)}円"]
    ]
    
    pdf.table(items, width: 510) do |table|
      table.row(0).background_color = "cccccc"
      table.row(0).font_style = :bold
      table.row(0).align = :center
      table.column(2).align = :right
      table.cells.padding = [5, 10, 5, 10]
      table.cells.borders = [:bottom]
      table.row(0).borders = [:bottom, :top]
      table.row(-1).borders = [:bottom]
    end
    
    pdf.move_down 30
    
    # 振込先情報
    pdf.text "お振込先", size: 14, style: :bold
    pdf.stroke_horizontal_rule
    pdf.move_down 10
    
    pdf.text "銀行名: AIサービス銀行 本店", size: 10
    pdf.text "口座種別: 普通口座", size: 10
    pdf.text "口座番号: 1234567", size: 10
    pdf.text "口座名義: カ）エーアイディーディー", size: 10
    
    pdf.move_down 40
    
    # 備考
    pdf.text "備考:", size: 14, style: :bold
    pdf.stroke_horizontal_rule
    pdf.move_down 10
    
    pdf.text "1. この度は弊社サービスをご利用いただき、誠にありがとうございます。", size: 10
    pdf.text "2. お支払いは請求書発行日より30日以内にお願いいたします。", size: 10
    pdf.text "3. 振込手数料は貴社負担でお願いいたします。", size: 10
    pdf.text "4. ご不明な点がございましたら、下記までお問い合わせください。", size: 10
    pdf.text "　 お問い合わせ先: support@aidd.example.com", size: 10
    
    # フッター
    pdf.number_pages "ページ <page> / <total>", {
      start_count_at: 1,
      at: [0, 0],
      align: :center,
      size: 9
    }
    
    # 透かし（支払済みの場合）
    if invoice.paid
      pdf.rotate(30, origin: [250, 400]) do
        pdf.fill_color "99999933"
        pdf.text_box "支払済", size: 100, at: [100, 380], width: 300
        pdf.fill_color "000000"
      end
    end
    
    # PDF文書のバイナリデータを取得
    pdf.render
  end
end
