import Foundation
import FirebaseAuth

class AuthManager {
    static let shared = AuthManager()
    
    // Mevcut kullanıcının ID'sini döndürür
    var currentUserID: String? {
        return Auth.auth().currentUser?.uid
    }
    
    // Anonim giriş yapar
    func signInAnonymously() {
        // Eğer zaten bir kullanıcı varsa tekrar giriş yapma
        if Auth.auth().currentUser == nil {
            Auth.auth().signInAnonymously { authResult, error in
                if let error = error {
                    print("Anonim Giriş Hatası: \(error.localizedDescription)")
                } else {
                    print("Anonim Giriş Başarılı! UID: \(authResult?.user.uid ?? "")")
                }
            }
        }
    }
}
