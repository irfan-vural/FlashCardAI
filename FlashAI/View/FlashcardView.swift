import SwiftUI

struct FlashcardView: View {
    let card: Flashcard
    
    @State private var rotation: Double = 0
    @State private var isFlipped: Bool = false
    
    var body: some View {
        ZStack {
            // Arka Yüz (Cevap - AI Temasına Uygun Mor/Mavi Gradient)
            CardFace(
                text: card.answer,
                isQuestion: false,
                colors: [Color.purple.opacity(0.9), Color.blue.opacity(0.8)]
            )
            .opacity(isFlipped ? 1 : 0)
            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            
            // Ön Yüz (Soru - Temiz, Modern Beyaz/Açık Gri)
            CardFace(
                text: card.question,
                isQuestion: true,
                colors: [Color.white, Color(UIColor.systemGray6)]
            )
            .opacity(isFlipped ? 0 : 1)
        }
        .frame(width: 320, height: 220) // Boyutu biraz daha altın orana yaklaştırdık
        .rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 1, z: 0))
        .onTapGesture {
            // Animasyonu biraz daha yaylı (spring) ve pürüzsüz hale getirdik
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0)) {
                rotation += 180
                isFlipped.toggle()
            }
        }
    }
}

// Kartın yüzeyini çizen yenilenmiş alt bileşen
struct CardFace: View {
    let text: String
    let isQuestion: Bool
    let colors: [Color]
    
    var body: some View {
        ZStack {
            // 1. Arka Plan ve Gölgelendirme
            RoundedRectangle(cornerRadius: 25, style: .continuous) // Apple'ın kullandığı pürüzsüz köşe dönüşü
                .fill(LinearGradient(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing))
                .shadow(color: Color.black.opacity(isQuestion ? 0.1 : 0.25), radius: 15, x: 0, y: 8)
            
            // 2. Cam Efekti İçin İnce Kenarlık (Stroke)
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .stroke(Color.white.opacity(isQuestion ? 0.6 : 0.2), lineWidth: 1)
            
            // 3. İçerik Düzeni
            VStack {
                // Üst Etiket (Soru/Cevap İkonu)
                HStack {
                    Image(systemName: isQuestion ? "questionmark.bubble.fill" : "sparkles")
                        .foregroundColor(isQuestion ? .gray : .yellow)
                    Text(isQuestion ? "SORU" : "YAPAY ZEKA CEVABI")
                        .font(.caption.bold())
                        .foregroundColor(isQuestion ? .gray : .white.opacity(0.9))
                    Spacer()
                }
                .padding([.top, .leading, .trailing], 20)
                
                Spacer()
                
                // Ana Metin (Dinamik boyutlandırma ile uzun metinler sığar)
                Text(text)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(isQuestion ? .primary : .white)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.7) // Yazı uzunsa taşırmak yerine biraz küçültür
                    .padding(.horizontal, 16)
                
                Spacer()
                
                // Alt Bilgi (Kullanıcı Yönlendirmesi)
                Text("Çevirmek için dokun")
                    .font(.caption2)
                    .foregroundColor(isQuestion ? .gray.opacity(0.6) : .white.opacity(0.6))
                    .padding(.bottom, 15)
            }
        }
    }
}
