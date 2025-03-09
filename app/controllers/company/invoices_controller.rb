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
    
    # ヘッダー部分
    pdf.text "請求書", size: 24, style: :bold, align: :center
    pdf.move_down 20
    
    # 日付と請求番号
    pdf.text "請求番号: #{invoice.id}", size: 12
    pdf.text "発行日: #{invoice.occurred_at.strftime('%Y年%m月%d日')}", size: 12
    pdf.text "支払期限: #{(invoice.occurred_at + 30.days).strftime('%Y年%m月%d日')}", size: 12
    pdf.move_down 20
    
    # 請求先情報
    pdf.text "請求先:", size: 14, style: :bold
    pdf.text "#{invoice.company_user.company_profile.company_name} 御中", size: 12
    pdf.move_down 20
    
    # 請求元情報
    pdf.text "請求元:", size: 14, style: :bold
    pdf.text "AIDD株式会社", size: 12
    pdf.text "〒100-0001 東京都千代田区1-1-1", size: 12
    pdf.text "TEL: 03-1234-5678", size: 12
    pdf.text "Email: billing@aidd.example.com", size: 12
    
    pdf.move_down 30
    
    # 支払状況
    pdf.text "支払状況: #{invoice.paid ? '支払済' : '未払い'}", size: 12
    pdf.move_down 20
    
    # 請求内容
    pdf.text "請求内容:", size: 14, style: :bold
    pdf.move_down 10
    
    # 対象情報
    pdf.text "・マッチング手数料", size: 12
    pdf.text "　求人: #{invoice.job.title}", size: 12
    pdf.text "　求職者: #{invoice.individual_user.individual_profile&.display_name || invoice.individual_user.user_id}", size: 12
    pdf.text "　マッチング成立日: #{invoice.occurred_at.strftime('%Y年%m月%d日')}", size: 12
    
    pdf.move_down 30
    
    # 請求金額
    pdf.text "請求金額:", size: 16, style: :bold
    pdf.text "#{invoice.amount.to_s(:delimited)}円（税込）", size: 16
    
    pdf.move_down 40
    
    # 振込先情報
    pdf.text "お振込先", size: 14, style: :bold
    pdf.move_down 10
    
    pdf.text "銀行名: AIサービス銀行 本店", size: 12
    pdf.text "口座種別: 普通口座", size: 12
    pdf.text "口座番号: 1234567", size: 12
    pdf.text "口座名義: カ）エーアイディーディー", size: 12
    
    pdf.move_down 40
    
    # 備考
    pdf.text "備考:", size: 14, style: :bold
    pdf.move_down 10
    
    pdf.text "1. この度は弊社サービスをご利用いただき、誠にありがとうございます。", size: 12
    pdf.text "2. お支払いは請求書発行日より30日以内にお願いいたします。", size: 12
    pdf.text "3. 振込手数料は貴社負担でお願いいたします。", size: 12
    pdf.text "4. ご不明な点がございましたら、support@aidd.example.com までお問い合わせください。", size: 12
    
    # PDF文書のバイナリデータを取得
    pdf.render
  end
end
