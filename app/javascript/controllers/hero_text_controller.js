import { Controller } from "@hotwired/stimulus"

// ヒーローセクションのテキストを切り替えるコントローラー
export default class extends Controller {
  static targets = ["headline", "description"]
  static values = {
    headlines: Array,
    descriptions: Array,
    index: { type: Number, default: 0 },
    interval: { type: Number, default: 5000 } // 5秒ごとに切り替え
  }

  connect() {
    console.log("Hero text controller connected - シンプル版")
    
    // 最もシンプルな実装
    try {
      if (!this.hasHeadlineTarget || !this.hasDescriptionTarget) {
        console.error("Missing targets")
        return
      }
      
      // 初期インデックス
      this.indexValue = 0
      
      // セットアップ
      this.setupTimer()
    } catch (e) {
      console.error("Setup error:", e)
    }
  }
  
  disconnect() {
    clearInterval(this.timer)
  }
  
  setupTimer() {
    // 必要な情報を出力
    console.log("Headlines length:", this.headlinesValue.length)
    console.log("First headline:", this.headlinesValue[0])
    
    // 初期表示
    this.updateDisplay()
    
    // タイマー設定
    this.timer = setInterval(() => {
      this.indexValue = (this.indexValue + 1) % this.headlinesValue.length
      this.updateDisplay()
    }, this.intervalValue)
  }
  
  updateDisplay() {
    try {
      console.log("Updating display to index:", this.indexValue)
      
      // コンテンツの更新
      this.headlineTarget.innerHTML = this.headlinesValue[this.indexValue]
      this.descriptionTarget.innerHTML = this.descriptionsValue[this.indexValue]
    } catch (e) {
      console.error("Update display error:", e)
    }
  }
} 