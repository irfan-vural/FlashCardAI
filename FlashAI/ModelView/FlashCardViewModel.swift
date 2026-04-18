import Foundation
import Observation
import FirebaseAILogic // En güncel kütüphanemizi ekliyoruz
import FirebaseFirestore

@Observable
class FlashcardViewModel {
    var flashcards: [Flashcard] = []
    var isGenerating: Bool = false
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration? // Dinleyiciyi takip etmek için
    // Parametresiz init kalabilir, başlangıç değerlerini zaten yukarıda verdik
    init() {
        subscribeToFirestore()
    }
    func subscribeToFirestore() {
            guard let uid = AuthManager.shared.currentUserID else { return }
            
            // Eski dinleyici varsa temizle
            listener?.remove()
            
            // Sorgu: Sadece bana ait kartları getir ve tarihe göre diz
            listener = db.collection("flashcards")
                .whereField("ownerId", isEqualTo: uid)
                .order(by: "createdAt", descending: true)
                .addSnapshotListener { querySnapshot, error in
                    if let error = error {
                        print("Firestore Hatası: \(error.localizedDescription)")
                        return
                    }
                    
                    // Firestore dökümanlarını Swift modellerine dönüştür
                    self.flashcards = querySnapshot?.documents.compactMap { document in
                        try? document.data(as: Flashcard.self)
                    } ?? []
                }
        }
    // ViewModel içindeki addCard fonksiyonunu şununla değiştir:
        func addCard(question: String, answer: String, category: String, sub1: String, sub2: String) {
            guard let uid = AuthManager.shared.currentUserID else { return }
            
            // Verileri temizle ve BÜYÜK HARFE çevir (Boş bırakılanları "GENEL" gibi bir kelimeye atayabilirsin veya boş bırakabilirsin)
            let cleanCategory = category.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
            let cleanSub1 = sub1.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
            let cleanSub2 = sub2.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
            
            let newCard = Flashcard(
                ownerId: uid,
                question: question.trimmingCharacters(in: .whitespacesAndNewlines),
                answer: answer.trimmingCharacters(in: .whitespacesAndNewlines),
                category: cleanCategory.isEmpty ? "DİĞER" : cleanCategory,
                subCategory1: cleanSub1,
                subCategory2: cleanSub2
            )
            
            do {
                _ = try db.collection("flashcards").addDocument(from: newCard)
            } catch {
                print("Kaydetme hatası: \(error)")
            }
        }
    // Mevcut kartlardan benzersiz ana kategorileri çeker
    var uniqueCategories: [String] {
        Array(Set(flashcards.map { $0.category })).sorted()
    }

    // Seçilen ana kategoriye ait alt kategorileri çeker
    func uniqueSubCategories1(for category: String) -> [String] {
        Array(Set(flashcards.filter { $0.category == category }.map { $0.subCategory1 })).sorted()
    }

    // Seçilen alt kategoriye ait en alt kategorileri çeker
    func uniqueSubCategories2(for sub1: String) -> [String] {
        Array(Set(flashcards.filter { $0.subCategory1 == sub1 }.map { $0.subCategory2 })).sorted()
    }
    
    // 4. Kart Silme Fonksiyonu
        func deleteCard(_ card: Flashcard) {
            // Kartın ID'si Firestore'da var mı diye kontrol ediyoruz
            guard let documentId = card.id else { return }
            
            // Firestore'dan o dökümanı siliyoruz
            db.collection("flashcards").document(documentId).delete { error in
                if let error = error {
                    print("Kart silinirken hata oluştu: \(error.localizedDescription)")
                } else {
                    print("Kart başarıyla silindi!")
                }
            }
        }
    func generateAnswerFor(question: String) async -> String {
        // İŞTE YENİ SİSTEMDEKİ DOĞRU KULLANIM:
        // Önce backend altyapısını seçerek (ücretsiz katman için googleAI) bağlantıyı kuruyoruz
        let ai = FirebaseAI.firebaseAI(backend: .googleAI())
        
        // Sonra senin harika seçimin olan flash-lite modelini çağırıyoruz
        let model = ai.generativeModel(modelName: "gemini-2.5-flash-lite")
        
        let prompt = """
        Sen bir flashcard uygulamasının arka yüzüsün. Görevin, verilen soruya veya terime doğrudan, 1-2 cümlelik kısa ve net bir cevap üretmektir. 
        
        KESİN KURALLAR:
        - Soruyu asla tekrar etme.
        - "Cevap:", "Açıklama:" gibi hiçbir ön ek veya başlık kullanma.
        - Kalın yazı (**), liste veya markdown işaretleri kullanma.
        - Sadece ve sadece cevabın kendisini düz metin olarak ver.
        
        Soru: \(question)
        """
        
        do {
            let response = try await model.generateContent(prompt)
            if let text = response.text {
                return text
            }
        } catch {
            print("Yapay Zeka Hatası: \(error.localizedDescription)")
            return "Cevap üretilemedi, lütfen tekrar dene."
        }
        return ""
    }
}
