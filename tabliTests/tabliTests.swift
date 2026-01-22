//
//  tabliTests.swift
//  tabliTests
//
//  Created by Tahsin Mert Mutlu on 02.11.2025.
//

import Testing
@testable import tabli

// MARK: - MenuItem Tests
struct MenuItemTests {
    
    @Test func testMenuItemInitialization() async throws {
        let menuItem = MenuItem(
            name: "İskender",
            description: "Lezzetli döner kebap",
            price: 150.0,
            imageName: "iskender",
            category: .foods
        )
        
        #expect(menuItem.name == "İskender")
        #expect(menuItem.description == "Lezzetli döner kebap")
        #expect(menuItem.price == 150.0)
        #expect(menuItem.imageName == "iskender")
        #expect(menuItem.category == .foods)
    }
    
    @Test func testMenuItemEquality() async throws {
        let id = UUID()
        let item1 = MenuItem(id: id, name: "Test", description: "Desc", price: 10.0, imageName: "test", category: .foods)
        let item2 = MenuItem(id: id, name: "Test", description: "Desc", price: 10.0, imageName: "test", category: .foods)
        
        #expect(item1 == item2)
    }
}

// MARK: - MenuCategory Tests
struct MenuCategoryTests {
    
    @Test func testAllCategoriesExist() async throws {
        let categories = MenuCategory.allCases
        #expect(categories.count == 4)
        #expect(categories.contains(.foods))
        #expect(categories.contains(.drinks))
        #expect(categories.contains(.desserts))
        #expect(categories.contains(.extras))
    }
    
    @Test func testCategoryIcons() async throws {
        #expect(MenuCategory.foods.icon == "🍖")
        #expect(MenuCategory.drinks.icon == "🥤")
        #expect(MenuCategory.desserts.icon == "🍮")
        #expect(MenuCategory.extras.icon == "🥗")
    }
    
    @Test func testPortionOptionOnlyForFoods() async throws {
        #expect(MenuCategory.foods.hasPortionOption == true)
        #expect(MenuCategory.drinks.hasPortionOption == false)
        #expect(MenuCategory.desserts.hasPortionOption == false)
        #expect(MenuCategory.extras.hasPortionOption == false)
    }
}

// MARK: - PortionSize Tests
struct PortionSizeTests {
    
    @Test func testPortionMultipliers() async throws {
        #expect(PortionSize.normal.multiplier == 1.0)
        #expect(PortionSize.birBucuk.multiplier == 1.5)
        #expect(PortionSize.duble.multiplier == 2.0)
    }
    
    @Test func testPortionDisplayNames() async throws {
        #expect(PortionSize.normal.displayName == "Normal")
        #expect(PortionSize.birBucuk.displayName == "1.5 Porsiyon")
        #expect(PortionSize.duble.displayName == "Duble")
    }
}

// MARK: - OrderItem Tests
struct OrderItemTests {
    
    @Test func testOrderItemTotalPrice() async throws {
        let menuItem = MenuItem(
            name: "Test Item",
            description: "Test",
            price: 100.0,
            imageName: "test",
            category: .foods
        )
        
        let orderItem = OrderItem(menuItem: menuItem, quantity: 2, portionSize: .normal)
        #expect(orderItem.totalPrice == 200.0) // 100 * 2 * 1.0
    }
    
    @Test func testOrderItemTotalPriceWithDuble() async throws {
        let menuItem = MenuItem(
            name: "Test Item",
            description: "Test",
            price: 100.0,
            imageName: "test",
            category: .foods
        )
        
        let orderItem = OrderItem(menuItem: menuItem, quantity: 2, portionSize: .duble)
        #expect(orderItem.totalPrice == 400.0) // 100 * 2 * 2.0
    }
    
    @Test func testOrderItemTotalPriceWithBirBucuk() async throws {
        let menuItem = MenuItem(
            name: "Test Item",
            description: "Test",
            price: 100.0,
            imageName: "test",
            category: .foods
        )
        
        let orderItem = OrderItem(menuItem: menuItem, quantity: 1, portionSize: .birBucuk)
        #expect(orderItem.totalPrice == 150.0) // 100 * 1 * 1.5
    }
}

// MARK: - Table Tests
struct TableTests {
    
    @Test func testAvailableTables() async throws {
        let tables = Table.availableTables
        #expect(tables.count == 20)
        #expect(tables.first?.number == 1)
        #expect(tables.last?.number == 20)
    }
    
    @Test func testTableEquality() async throws {
        let table1 = Table(id: 1, number: 1)
        let table2 = Table(id: 1, number: 1)
        #expect(table1 == table2)
    }
}

// MARK: - OrderStatus Tests
struct OrderStatusTests {
    
    @Test func testOrderStatusRawValues() async throws {
        #expect(OrderStatus.none.rawValue == "None")
        #expect(OrderStatus.pending.rawValue == "Pending")
        #expect(OrderStatus.preparing.rawValue == "Preparing")
        #expect(OrderStatus.ready.rawValue == "Ready")
        #expect(OrderStatus.completed.rawValue == "Completed")
    }
}

// MARK: - User Tests
struct UserTests {
    
    @Test func testUserInitializationWithDefaults() async throws {
        let user = User()
        
        #expect(user.name == "")
        #expect(user.email == "")
        #expect(user.phoneNumber == "")
        #expect(user.profileImageData == nil)
        #expect(user.role == .customer)
    }
    
    @Test func testUserInitializationWithValues() async throws {
        let user = User(
            name: "Selim Can",
            email: "selim@test.com",
            phoneNumber: "555-1234",
            role: .admin
        )
        
        #expect(user.name == "Selim Can")
        #expect(user.email == "selim@test.com")
        #expect(user.phoneNumber == "555-1234")
        #expect(user.role == .admin)
    }
    
    @Test func testUserRoles() async throws {
        #expect(UserRole.customer.rawValue == "customer")
        #expect(UserRole.admin.rawValue == "admin")
    }
}

// MARK: - UserPreferences Tests
struct UserPreferencesTests {
    
    @Test func testDefaultPreferences() async throws {
        let prefs = UserPreferences()
        
        #expect(prefs.favoriteCategories.isEmpty)
        #expect(prefs.dietaryRestrictions.isEmpty)
        #expect(prefs.preferredLanguage == .turkish)
        #expect(prefs.notificationsEnabled == true)
        #expect(prefs.darkModeEnabled == false)
    }
    
    @Test func testCustomPreferences() async throws {
        let prefs = UserPreferences(
            favoriteCategories: [.foods, .desserts],
            dietaryRestrictions: ["Gluten-free"],
            preferredLanguage: .english,
            notificationsEnabled: false,
            darkModeEnabled: true
        )
        
        #expect(prefs.favoriteCategories.count == 2)
        #expect(prefs.dietaryRestrictions.contains("Gluten-free"))
        #expect(prefs.preferredLanguage == .english)
        #expect(prefs.notificationsEnabled == false)
        #expect(prefs.darkModeEnabled == true)
    }
}

// MARK: - OrderHistoryItem Tests
struct OrderHistoryItemTests {
    
    @Test func testOrderHistoryItemInitialization() async throws {
        let menuItem = MenuItem(
            name: "Test",
            description: "Desc",
            price: 50.0,
            imageName: "test",
            category: .foods
        )
        let orderItem = OrderItem(menuItem: menuItem, quantity: 2)
        let table = Table(id: 1, number: 1)
        
        let historyItem = OrderHistoryItem(
            id: UUID(),
            items: [orderItem],
            table: table,
            totalPrice: 100.0,
            date: Date(),
            notes: "Az acılı"
        )
        
        #expect(historyItem.items.count == 1)
        #expect(historyItem.table.number == 1)
        #expect(historyItem.totalPrice == 100.0)
        #expect(historyItem.notes == "Az acılı")
    }
}

// MARK: - QR Code Parsing Tests
struct QRCodeParsingTests {
    
    @Test func testQRCodeParsingWithPrefix() async throws {
        // Simulate QR code parsing logic
        let code = "table-5"
        let tableNumber = code
            .replacingOccurrences(of: "table-", with: "", options: .caseInsensitive)
            .trimmingCharacters(in: .whitespaces)
        
        #expect(tableNumber == "5")
        #expect(Int(tableNumber) == 5)
    }
    
    @Test func testQRCodeParsingWithoutPrefix() async throws {
        let code = "7"
        let tableNumber = code
            .replacingOccurrences(of: "table-", with: "", options: .caseInsensitive)
            .trimmingCharacters(in: .whitespaces)
        
        #expect(tableNumber == "7")
        #expect(Int(tableNumber) == 7)
    }
    
    @Test func testQRCodeParsingUpperCase() async throws {
        let code = "TABLE-12"
        let tableNumber = code
            .replacingOccurrences(of: "table-", with: "", options: .caseInsensitive)
            .trimmingCharacters(in: .whitespaces)
        
        #expect(tableNumber == "12")
        #expect(Int(tableNumber) == 12)
    }
    
    @Test func testQRCodeParsingWithWhitespace() async throws {
        let code = "  table-3  "
        let tableNumber = code
            .replacingOccurrences(of: "table-", with: "", options: .caseInsensitive)
            .trimmingCharacters(in: .whitespaces)
        
        #expect(tableNumber == "3")
    }
    
    @Test func testInvalidQRCode() async throws {
        let code = "invalid-code"
        let tableNumber = code
            .replacingOccurrences(of: "table-", with: "", options: .caseInsensitive)
            .trimmingCharacters(in: .whitespaces)
        
        #expect(Int(tableNumber) == nil)
    }
}

// MARK: - Sample Data Tests
struct SampleDataTests {
    
    @Test func testSampleMenuNotEmpty() async throws {
        let menu = MenuItem.sampleMenu
        #expect(!menu.isEmpty)
    }
    
    @Test func testSampleMenuHasAllCategories() async throws {
        let menu = MenuItem.sampleMenu
        let categories = Set(menu.map { $0.category })
        
        #expect(categories.contains(.foods))
        #expect(categories.contains(.drinks))
        #expect(categories.contains(.desserts))
    }
    
    @Test func testAllMenuItemsHaveValidPrices() async throws {
        let menu = MenuItem.sampleMenu
        
        for item in menu {
            #expect(item.price > 0, "Menu item '\(item.name)' should have positive price")
        }
    }
    
    @Test func testAllMenuItemsHaveNames() async throws {
        let menu = MenuItem.sampleMenu
        
        for item in menu {
            #expect(!item.name.isEmpty, "Menu item should have a name")
        }
    }
}

// MARK: - Codable Tests
struct CodableTests {
    
    @Test func testMenuItemCodable() async throws {
        let original = MenuItem(
            name: "Test",
            description: "Desc",
            price: 99.99,
            imageName: "test",
            category: .foods
        )
        
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MenuItem.self, from: encoded)
        
        #expect(decoded.name == original.name)
        #expect(decoded.price == original.price)
        #expect(decoded.category == original.category)
    }
    
    @Test func testUserCodable() async throws {
        let original = User(
            name: "Test User",
            email: "test@test.com",
            role: .admin
        )
        
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(User.self, from: encoded)
        
        #expect(decoded.name == original.name)
        #expect(decoded.email == original.email)
        #expect(decoded.role == original.role)
    }
    
    @Test func testOrderStatusCodable() async throws {
        let original = OrderStatus.preparing
        
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(OrderStatus.self, from: encoded)
        
        #expect(decoded == original)
    }
    
    @Test func testTableCodable() async throws {
        let original = Table(id: 5, number: 5)
        
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Table.self, from: encoded)
        
        #expect(decoded == original)
    }
}

