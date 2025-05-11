
import CoreData
import CryptoKit

struct MYPersistenceController {
    static let shared = MYPersistenceController()
    
    @MainActor
    static let preview: MYPersistenceController = MYPersistenceController(inMemory: true)

    let container: NSPersistentCloudKitContainer

    private init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "EditPic")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func addUser(email: String, password: String) async throws {
        if try await doesEmailExist(email) {
            return
            //Тут должна быть более умная обработка
        }
        let context = container.viewContext
        let user = User(context: context)
        user.email = email
        user.passwordHash = hash(password)
        
        try context.save()
    }
    
    func addUser(email: String, name: String?) async throws {
        if let user = try await getEmail(email) {
            if user.name == nil {
                user.name = name
            }
            return
            //Тут должна быть более умная обработка
        }
        let context = container.viewContext
        let user = User(context: context)
        user.email = email
        user.name = name
        
        try context.save()
    }
    
    func doesEmailExist(_ email: String) async throws -> Bool {
        let context = container.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.predicate = NSPredicate(format: "email == %@", email)
        request.fetchLimit = 1
        request.includesPropertyValues = false

        return try context.count(for: request) > 0
    }
    
    func fetchUser(email: String, password: String) async throws -> User? {
        let context = container.viewContext
        let request = NSFetchRequest<User>(entityName: "User")
        request.predicate = NSPredicate(
            format: "email == %@ AND passwordHash == %@",
            email,
            hash(password)
        )
        request.fetchLimit = 1
        
        return try context.fetch(request).first
    }
    
    func getEmail(_ email: String) async throws -> User? {
        let context = container.viewContext
        let request = NSFetchRequest<User>(entityName: "User")
        request.predicate = NSPredicate(format: "email == %@", email)
        request.fetchLimit = 1
        
        return try context.fetch(request).first
    }
    
    private func hash(_ input: String) -> String {
        let data = Data(input.utf8)
        let hash = SHA256.hash(data: data)
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}
