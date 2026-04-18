import Foundation
import FirebaseFirestore

struct Flashcard: Identifiable, Codable {
    @DocumentID var id: String?
    var ownerId: String
    var question: String
    var answer: String
    
    // Hiyerarşik Kategori Yapısı
    var category: String      // Örn: Yazılım
    var subCategory1: String  // Örn: Web
    var subCategory2: String  // Örn: JavaScript
    
    var createdAt: Date = Date()
}
