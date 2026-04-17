import SwiftUI

struct SplashScreenView: View {
    // Animasyon için kullanacağımız state değişkenleri
    @State private var size = 0.6
    @State private var opacity = 0.4
    
    var body: some View {
        ZStack {
            // Arka plan rengi (Dark/Light mode uyumlu)
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // İkon (Uygulamanın Logosu gibi düşün)
                Image(systemName: "sparkles.rectangle.stack.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(gradient: Gradient(colors: [.purple, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                
                // Uygulama Adı
                Text("FlashAI")
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundColor(.primary)
                
                // Alt Başlık
                Text("Yapay Zeka Destekli Öğrenim")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .opacity(0.8)
            }
            // Başlangıç boyut ve görünürlüğü
            .scaleEffect(size)
            .opacity(opacity)
            // Ekran açıldığı anda animasyonu tetikle
            .onAppear {
                withAnimation(.easeIn(duration: 1.2)) {
                    self.size = 1.0 // Büyüyerek orijinal boyuta gelsin
                    self.opacity = 1.0 // Tamamen görünür olsun
                }
            }
        }
    }
}
