// ヒーローセクションのスライドショー - バックアップソリューション
document.addEventListener('DOMContentLoaded', function() {
  console.log("hero_slideshow.js loaded");
  
  // ヒーローセクションの要素
  const heroSection = document.querySelector('.hero-section');
  if (!heroSection) {
    console.error("Hero section not found");
    return;
  }
  
  // ヘッドラインと説明の要素
  const headline = document.querySelector('.hero-headline');
  const description = document.querySelector('.hero-description');
  
  if (!headline || !description) {
    console.error("Hero headline or description not found");
    return;
  }
  
  console.log("Hero elements found:", {headline, description});
  
  // テキストの配列
  const headlines = [
    'AI駆動開発エンジニアと<br/><span class="text-blue-500">企業の新しい</span>マッチング体験',
    '<span class="text-blue-500">最先端のAIツール</span>を<br/>使いこなす人材を探す',
    'AI時代の<br/><span class="text-blue-500">エンジニアキャリア</span>の第一歩',
    '<span class="text-blue-500">効率的な開発</span>と<br/>革新的なプロダクト開発',
    '企業と人材を<br/><span class="text-blue-500">AIの力</span>でつなぐ'
  ];
  
  const descriptions = [
    'AIDD.WORKは、Cursorなどのツールを使いこなすエンジニアと、<br/>最先端の開発スキルを求める企業をつなぐプラットフォームです。',
    'AI駆動開発のツールを活用できるエンジニアは、<br/>これからの時代に欠かせない貴重な人材です。',
    'AIツールを駆使する能力は、<br/>次世代のエンジニアに求められる最重要スキルです。',
    'AI駆動開発によって、<br/>開発速度と創造性の両方を高めた企業が成功します。',
    '人間とAIのベストな組み合わせで、<br/>これからのソフトウェア開発の形を創造しましょう。'
  ];
  
  let currentIndex = 0;
  const interval = 5000; // 5秒ごとに切り替え
  
  // テキストを更新する関数
  function updateText() {
    console.log(`Updating to text index ${currentIndex}`);
    
    // 要素をフェードアウト
    headline.style.opacity = 0;
    description.style.opacity = 0;
    
    // テキストを更新
    setTimeout(function() {
      headline.innerHTML = headlines[currentIndex];
      description.innerHTML = descriptions[currentIndex];
      
      // 要素をフェードイン
      headline.style.opacity = 1;
      description.style.opacity = 1;
      
      // インデックスを進める
      currentIndex = (currentIndex + 1) % headlines.length;
    }, 500);
  }
  
  // 初期テキストを表示
  headline.innerHTML = headlines[0];
  description.innerHTML = descriptions[0];
  currentIndex = 1;
  
  // スライドショーを開始
  setInterval(updateText, interval);
  
  console.log("Hero slideshow started");
}); 