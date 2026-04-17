import Foundation
import FirebaseFirestore // Bunu eklemeyi unutma

struct Flashcard: Identifiable, Codable {
    // @DocumentID, Firestore'daki döküman adını (ID) otomatik olarak bu alana yazar
    @DocumentID var id: String?
    var ownerId: String
    var question: String
    var answer: String
    var createdAt: Date = Date() // Kartları tarihe göre sıralamak için ekledik
}
