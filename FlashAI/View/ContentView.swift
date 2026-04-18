import SwiftUI

struct ContentView: View {
    @State private var viewModel = FlashcardViewModel()
    @State private var showingAddCard = false
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    // 1. Seçili Kategorileri Tutan Stateler
    @State private var selectedCategory: String = "HEPSİ"
    @State private var selectedSub1: String = "HEPSİ"
    @State private var selectedSub2: String = "HEPSİ"
    @State private var showingQuiz = false
    // 2. Filtrelenmiş Kartları Döndüren Hesaplanan Değişken
    var filteredCards: [Flashcard] {
        if selectedCategory == "HEPSİ" {
            return viewModel.flashcards
        } else if selectedSub1 == "HEPSİ" {
            return viewModel.flashcards.filter { $0.category == selectedCategory }
        } else if selectedSub2 == "HEPSİ" {
            return viewModel.flashcards.filter { $0.category == selectedCategory && $0.subCategory1 == selectedSub1 }
        } else {
            return viewModel.flashcards.filter { $0.category == selectedCategory && $0.subCategory1 == selectedSub1 && $0.subCategory2 == selectedSub2 }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    // --- 1. SEVİYE: ANA KATEGORİ MENÜSÜ ---
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            CategoryChip(title: "HEPSİ", isSelected: selectedCategory == "HEPSİ") {
                                withAnimation(.spring()) {
                                    selectedCategory = "HEPSİ"
                                    selectedSub1 = "HEPSİ"
                                    selectedSub2 = "HEPSİ" // Zincirleme sıfırlama
                                }
                            }
                            
                            ForEach(viewModel.uniqueCategories, id: \.self) { category in
                                if !category.isEmpty {
                                    CategoryChip(title: category, isSelected: selectedCategory == category) {
                                        withAnimation(.spring()) {
                                            selectedCategory = category
                                            selectedSub1 = "HEPSİ"
                                            selectedSub2 = "HEPSİ" // Zincirleme sıfırlama
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                    }
                    .background(Color(UIColor.systemGroupedBackground))
                    
                    // --- 2. SEVİYE: ALT KATEGORİ 1 (Sub1) MENÜSÜ ---
                    let subCategories1 = viewModel.uniqueSubCategories1(for: selectedCategory).filter { !$0.isEmpty }
                    
                    if selectedCategory != "HEPSİ" && !subCategories1.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                CategoryChip(title: "HEPSİ", isSelected: selectedSub1 == "HEPSİ") {
                                    withAnimation(.spring()) {
                                        selectedSub1 = "HEPSİ"
                                        selectedSub2 = "HEPSİ" // Zincirleme sıfırlama
                                    }
                                }
                                
                                ForEach(subCategories1, id: \.self) { sub1 in
                                    CategoryChip(title: sub1, isSelected: selectedSub1 == sub1) {
                                        withAnimation(.spring()) {
                                            selectedSub1 = sub1
                                            selectedSub2 = "HEPSİ" // Zincirleme sıfırlama
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 10)
                        }
                        .background(Color(UIColor.systemGroupedBackground))
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    // --- 3. SEVİYE: ALT KATEGORİ 2 (Sub2) MENÜSÜ ---
                    let subCategories2 = viewModel.uniqueSubCategories2(for: selectedSub1).filter { !$0.isEmpty }
                    
                    if selectedCategory != "HEPSİ" && selectedSub1 != "HEPSİ" && !subCategories2.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                CategoryChip(title: "HEPSİ", isSelected: selectedSub2 == "HEPSİ") {
                                    withAnimation(.spring()) { selectedSub2 = "HEPSİ" }
                                }
                                
                                ForEach(subCategories2, id: \.self) { sub2 in
                                    CategoryChip(title: sub2, isSelected: selectedSub2 == sub2) {
                                        withAnimation(.spring()) { selectedSub2 = sub2 }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 10)
                        }
                        .background(Color(UIColor.systemGroupedBackground))
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    // --- QUİZ BAŞLATMA BUTONU ---
                    if !filteredCards.isEmpty {
                        Button(action: {
                            showingQuiz = true
                        }) {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                    .font(.title2)
                                Text("\(filteredCards.count) Kart ile Quiz'e Başla")
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(gradient: Gradient(colors: [.orange, .red]), startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(15)
                            .shadow(color: .orange.opacity(0.4), radius: 8, y: 4)
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                        }
                    }

                    // --- 4. KARTLARIN LİSTESİ ---
                    ScrollView {
                        LazyVStack(spacing: 25) {
                            ForEach(filteredCards) { card in
                                FlashcardView(card: card)
                                    .contextMenu {
                                        Button(role: .destructive, action: {
                                            withAnimation { viewModel.deleteCard(card) }
                                        }) {
                                            Label("Kartı Sil", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 100)
                    }
                }
                
                // --- YÜZEN EKLEME BUTONU (FAB) ---
                VStack {
                    Spacer()
                    Button(action: { showingAddCard = true }) {
                        Image(systemName: "plus")
                            .font(.title.weight(.semibold))
                            .foregroundColor(.white)
                            .frame(width: 65, height: 65)
                            .background(LinearGradient(gradient: Gradient(colors: [.purple, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            .clipShape(Circle())
                            .shadow(color: .purple.opacity(0.4), radius: 10, x: 0, y: 5)
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Kartlarım")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        withAnimation(.easeInOut) { isDarkMode.toggle() }
                    }) {
                        Image(systemName: isDarkMode ? "moon.stars.fill" : "sun.max.fill")
                            .foregroundColor(isDarkMode ? .yellow : .orange)
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingAddCard) {
                AddCardView(viewModel: viewModel)
                    .preferredColorScheme(isDarkMode ? .dark : .light)
            }.fullScreenCover(isPresented: $showingQuiz) {
                QuizView(cards: filteredCards)
                    .preferredColorScheme(isDarkMode ? .dark : .light)
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
    
    // Yatay menüdeki şık kategori butonları
    struct CategoryChip: View {
        let title: String
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .bold : .medium)
                    .foregroundColor(isSelected ? .white : .primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(isSelected ? Color.purple : Color.gray.opacity(0.2))
                    )
            }
        }
    }
}
