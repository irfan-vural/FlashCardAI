import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    AuthManager.shared.signInAnonymously() // Anonim girişi tetikle
    return true
  }
}

@main
struct FlashAIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // Uygulamanın ana ekrana geçip geçmediğini kontrol eden state
    @State private var isActive = false
    
    // Kullanıcının tema tercihini en tepeden alıyoruz ki splash screen de uyum sağlasın
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if isActive {
                    // 2 saniye sonra burası çalışır ve ana ekran gelir
                    ContentView()
                } else {
                    // Uygulama ilk açıldığında burası çalışır
                    SplashScreenView()
                        .onAppear {
                            // 2.0 saniye bekle, sonra ana ekrana geç
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                // Ekran değişimini yumuşak bir geçiş (fade) ile yap
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    self.isActive = true
                                }
                            }
                        }
                }
            }
            // Tüm uygulamayı (Splash dâhil) seçilen temaya zorluyoruz
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}
