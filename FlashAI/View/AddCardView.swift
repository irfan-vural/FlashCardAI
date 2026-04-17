import SwiftUI

struct AddCardView: View {
    @Environment(\.dismiss) var dismiss
    var viewModel: FlashcardViewModel
    
    @State private var questionText: String = ""
    @State private var answerText: String = ""
    @State private var isLoadingAI: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Arka plan rengi
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        
                        // --- Soru Alanı ---
                        VStack(alignment: .leading, spacing: 8) {
                            Text("SORU VEYA KAVRAM")
                                .font(.caption.bold())
                                .foregroundColor(.gray)
                            
                            TextField("Örn: Perine nedir", text: $questionText)
                                .padding()
                                .background(Color(UIColor.secondarySystemGroupedBackground))
                                .cornerRadius(15)
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                        
                        // --- Yapay Zeka Aksiyon Butonu ---
                        Button(action: {
                            Task {
                                isLoadingAI = true
                                answerText = await viewModel.generateAnswerFor(question: questionText)
                                isLoadingAI = false
                            }
                        }) {
                            HStack {
                                if isLoadingAI {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Image(systemName: "sparkles")
                                }
                                Text(isLoadingAI ? "Yapay Zeka Düşünüyor..." : "Yapay Zeka İle Cevapla")
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(gradient: Gradient(colors: [.purple, .blue]), startPoint: .leading, endPoint: .trailing)
                            )
                            .foregroundColor(.white)
                            .cornerRadius(15)
                            .shadow(color: .purple.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        // Soru boşsa veya AI yükleniyorsa butonu pasif yap
                        .disabled(questionText.isEmpty || isLoadingAI)
                        .opacity((questionText.isEmpty || isLoadingAI) ? 0.6 : 1)
                        
                        // --- Cevap Alanı ---
                        VStack(alignment: .leading, spacing: 8) {
                            Text("CEVAP")
                                .font(.caption.bold())
                                .foregroundColor(.gray)
                            
                            TextField("Cevap buraya yazılacak...", text: $answerText, axis: .vertical)
                                .lineLimit(5...10) // Metin kutusu aşağı doğru büyüyebilir
                                .padding()
                                .background(Color(UIColor.secondarySystemGroupedBackground))
                                .cornerRadius(15)
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Yeni Kart")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // İptal Butonu
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                        .foregroundColor(.red)
                }
                // Kaydet Butonu
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        viewModel.addCard(question: questionText, answer: answerText)
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .disabled(questionText.isEmpty || answerText.isEmpty)
                }
            }
        }
    }
}
