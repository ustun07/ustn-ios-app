import Foundation

extension MenuItem {
    static let sampleMenu: [MenuItem] = [
        // MARK: - Yiyecekler (Foods)
        MenuItem(
            name: "İskender",
            description: "Bursa usulü tereyağlı döner, yoğurt ve özel sos ile",
            price: 240.00,
            imageName: "iskender",
            category: .foods
        ),
        MenuItem(
            name: "Köfte",
            description: "El yapımı ızgara köfte, pilav ve salata ile",
            price: 180.00,
            imageName: "köfte",
            category: .foods
        ),
        MenuItem(
            name: "Döner",
            description: "Yaprak et döner, pilav veya ekmek arası",
            price: 160.00,
            imageName: "döner",
            category: .foods
        ),
        
        // MARK: - İçecekler (Drinks)
        MenuItem(
            name: "Su",
            description: "Doğal kaynak suyu 500ml",
            price: 15.00,
            imageName: "su",
            category: .drinks
        ),
        MenuItem(
            name: "Kola",
            description: "Soğuk kutu içecek 330ml",
            price: 35.00,
            imageName: "kola",
            category: .drinks
        ),
        MenuItem(
            name: "Ayran",
            description: "Geleneksel Türk yoğurt içeceği",
            price: 25.00,
            imageName: "ayran",
            category: .drinks
        ),
        
        // MARK: - Tatlılar (Desserts)
        MenuItem(
            name: "Sütlaç",
            description: "Fırında pişmiş geleneksel sütlaç",
            price: 80.00,
            imageName: "sutlac",
            category: .desserts
        ),
        MenuItem(
            name: "Kabak Tatlısı",
            description: "Kaymaklı geleneksel kabak tatlısı",
            price: 90.00,
            imageName: "kabak",
            category: .desserts
        ),
        MenuItem(
            name: "Baklava",
            description: "Fıstıklı ve cevizli seçeneği ile geleneksel baklava",
            price: 100.00,
            imageName: "baklava",
            category: .desserts
        ),
        
        // MARK: - Ekstralar (Extras)
        MenuItem(
            name: "Yoğurt",
            description: "Ev yapımı süzme yoğurt",
            price: 30.00,
            imageName: "yoğurt",
            category: .extras
        ),
        MenuItem(
            name: "Köz Biber",
            description: "Közlenmiş tatlı biber",
            price: 25.00,
            imageName: "köz biber",
            category: .extras
        ),
        MenuItem(
            name: "Köz Patlıcan",
            description: "Közlenmiş patlıcan",
            price: 30.00,
            imageName: "koz_patlican",
            category: .extras
        ),
        MenuItem(
            name: "Piyaz",
            description: "Geleneksel fasulye salatası",
            price: 25.00,
            imageName: "piyaz",
            category: .extras
        )
    ]
}
