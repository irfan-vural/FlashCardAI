import SwiftUI

struct ContentView: View {
    @State private var viewModel = FlashcardViewModel()
    @State private var showingAddCard = false
    
    // Kullanıcının tema seçimini telefona kaydediyoruz
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 1. Arka Plan (Temaya göre otomatik değişir)
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                // 2. Kartların Listesi
                ScrollView {
                    LazyVStack(spacing: 25) {
                        ForEach(viewModel.flashcards) { card in
                            FlashcardView(card: card)
                                .contextMenu{
                                    Button(role: .destructive, action: {
                                                            // Silme animasyonu ile birlikte fonksiyonu çağırıyoruz
                                                            withAnimation {
                                                                viewModel.deleteCard(card)
                                                            }
                                                        }) {
                                                            Label("Kartı Sil", systemImage: "trash")
                                                        }
                                }
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 100) // Alttaki buton kartların üstünü kapatmasın diye boşluk
                }
                
                // 3. Alt Merkezdeki Yüzen Buton (Floating Action Button)
                VStack {
                    Spacer()
                    Button(action: {
                        showingAddCard = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title.weight(.semibold))
                            .foregroundColor(.white)
                            .frame(width: 65, height: 65)
                            .background(
                                LinearGradient(gradient: Gradient(colors: [.purple, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .clipShape(Circle())
                            .shadow(color: .purple.opacity(0.4), radius: 10, x: 0, y: 5)
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Kartlarım")
            .toolbar {
                // 4. Üst Kısımdaki Dark Mode Toggle Butonu
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        withAnimation(.easeInOut) { // Tatlı bir geçiş animasyonu
                            isDarkMode.toggle()
                        }
                    }) {
                        Image(systemName: isDarkMode ? "moon.stars.fill" : "sun.max.fill")
                            .foregroundColor(isDarkMode ? .yellow : .orange)
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingAddCard) {
                AddCardView(viewModel: viewModel)
                    // Sayfa açıldığında ana ekranın temasını miras alsın
                    .preferredColorScheme(isDarkMode ? .dark : .light)
            }
        }
        // Tüm uygulamayı seçilen temaya zorluyoruz
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}
