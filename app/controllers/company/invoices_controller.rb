class Company::InvoicesController < ApplicationController
  before_action :require_login
  before_action :ensure_company_user
  before_action :set_invoice, only: [:show, :mark_as_paid, :download_pdf, :print_preview]
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
  
  # 印刷用のプレビューを表示するアクション
  def print_preview
    render layout: 'print'
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
    # Prawnをrequireして基本的なPDFを生成
    require 'prawn'
    
    begin
      # 最もシンプルな設定でPDFを作成
      pdf = Prawn::Document.new
      
      # 英語のみの内容を追加
      pdf.text "INVOICE", size: 20, align: :center
      pdf.move_down 20
      
      pdf.text "Invoice Number: #{invoice.id}"
      pdf.text "Date: #{invoice.occurred_at.strftime('%Y/%m/%d')}"
      
      pdf.move_down 20
      pdf.text "Bill To: #{invoice.company_user.company_profile.company_name}"
      
      pdf.move_down 20
      pdf.text "From: AIDD Company"
      
      pdf.move_down 20
      pdf.text "Job Title: #{invoice.job.title}"
      pdf.text "Candidate ID: #{invoice.individual_user.user_id}"
      
      pdf.move_down 20
      pdf.text "Amount: JPY #{invoice.amount.to_s(:delimited)}", size: 16
      
      # 最後にPDFデータを返す
      return pdf.render
    rescue => e
      # エラーが発生した場合はログに出力して簡易PDFを返す
      Rails.logger.error "PDF Error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      
      # 最小限のPDFを作成して返す
      simple_pdf = Prawn::Document.new
      simple_pdf.text "INVOICE (Simple View)", size: 16
      simple_pdf.move_down 10
      simple_pdf.text "Invoice ID: #{invoice.id}"
      simple_pdf.text "Amount: JPY #{invoice.amount.to_s(:delimited)}"
      simple_pdf.render
    end
  end
end
