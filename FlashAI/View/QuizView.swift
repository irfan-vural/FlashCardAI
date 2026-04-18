import SwiftUI

struct QuizView: View {
    let cards: [Flashcard] // Dışarıdan gelecek filtrelenmiş kartlar
    @Environment(\.dismiss) var dismiss // Ekranı kapatmak için
    
    // Quiz durumunu takip eden State'ler
    @State private var currentIndex = 0
    @State private var correctCount = 0
    @State private var wrongCount = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                // 1. DURUM: Kart Yoksa
                if cards.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "rectangle.stack.badge.minus")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("Bu kategoride henüz kart yok.")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                }
                // 2. DURUM: Quiz Bittiyse (Skor Ekranı)
                else if currentIndex >= cards.count {
                    VStack(spacing: 30) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom))
                        
                        Text("Quiz Tamamlandı!")
                            .font(.largeTitle.bold())
                        
                        HStack(spacing: 40) {
                            VStack {
                                Text("\(correctCount)")
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(.green)
                                Text("Doğru")
                                    .fontWeight(.medium)
                            }
                            
                            VStack {
                                Text("\(wrongCount)")
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(.red)
                                Text("Yanlış")
                                    .fontWeight(.medium)
                            }
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
                        
                        Button("Bitir") {
                            dismiss()
                        }
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.purple)
                        .cornerRadius(15)
                        .padding(.top, 20)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
                // 3. DURUM: Quiz Devam Ediyorsa (Oyun Ekranı)
                else {
                    VStack {
                        // Üst Bilgi Barı (İlerleme)
                        VStack(spacing: 8) {
                            Text("Kart \(currentIndex + 1) / \(cards.count)")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            ProgressView(value: Double(currentIndex), total: Double(cards.count))
                                .tint(.purple)
                                .padding(.horizontal, 40)
                        }
                        .padding(.top, 20)
                        
                        Spacer()
                        
                        // Kartın Kendisi
                        FlashcardView(card: cards[currentIndex])
                            // MÜHENDİSLİK DETAYI: id() eklemezsek SwiftUI eski kartın dönmüş halini yeni karta kopyalar.
                            // id(card.id) diyerek kart değiştiğinde View'ın tamamen sıfırlanmasını sağlıyoruz.
                            .id(cards[currentIndex].id)
                            // Kartlar arası geçişte sağdan/soldan gelme animasyonu
                            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                        
                        Spacer()
                        
                        // Doğru / Yanlış Butonları
                        HStack(spacing: 30) {
                            // Yanlış Butonu
                            Button(action: {
                                nextCard(correct: false)
                            }) {
                                HStack {
                                    Image(systemName: "xmark")
                                    Text("Yanlış")
                                }
                                .font(.title3.bold())
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(Color.red.opacity(0.8))
                                .cornerRadius(15)
                                .shadow(color: .red.opacity(0.3), radius: 5, y: 3)
                            }
                            
                            // Doğru Butonu
                            Button(action: {
                                nextCard(correct: true)
                            }) {
                                HStack {
                                    Image(systemName: "checkmark")
                                    Text("Doğru")
                                }
                                .font(.title3.bold())
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(Color.green.opacity(0.8))
                                .cornerRadius(15)
                                .shadow(color: .green.opacity(0.3), radius: 5, y: 3)
                            }
                        }
                        .padding(.horizontal, 30)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("Quiz Modu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") { dismiss() }
                }
            }
        }
    }
    
    // Kart değiştirme ve skor tutma fonksiyonu
    private func nextCard(correct: Bool) {
        if correct {
            correctCount += 1
        } else {
            wrongCount += 1
        }
        
        // Animasyonla bir sonraki karta geç
        withAnimation(.easeInOut(duration: 0.3)) {
            currentIndex += 1
        }
    }
}
