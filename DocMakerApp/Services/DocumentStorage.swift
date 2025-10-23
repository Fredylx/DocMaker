import Foundation
import CoreData
import CloudKit

@MainActor
final class DocumentStorage: ObservableObject {
    static let shared = DocumentStorage()

    @Published private(set) var documents: [DocumentMetadata] = []

    private let container: NSPersistentContainer
    private let backgroundContext: NSManagedObjectContext

    private init() {
        let model = DocumentStorage.makeModel()
        container = NSPersistentContainer(name: "DocMakerModel", managedObjectModel: model)
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        container.loadPersistentStores { _, error in
            if let error = error {
#if DEBUG
                print("Failed to load persistent stores: \(error.localizedDescription)")
#endif
            }
        }

        backgroundContext = container.newBackgroundContext()
        backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        Task {
            await fetchDocuments()
            await seedDemoDocumentsIfNeeded()
        }
    }

    func data(for documentID: UUID) -> Data? {
        let request = NSFetchRequest<StoredDocument>(entityName: "StoredDocument")
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "id == %@", documentID as CVarArg)

        var pdfData: Data?
        container.viewContext.performAndWait {
            pdfData = try? container.viewContext.fetch(request).first?.pdfData
        }
        return pdfData
    }

    func storeDocument(data: Data, title: String, uploadToCloud: Bool = true) async throws -> DocumentMetadata {
        let metadata = DocumentMetadata(title: title, fileSize: data.count, createdAt: Date())

        try await performBackgroundWork {
            let stored = StoredDocument(context: self.backgroundContext)
            stored.id = metadata.id
            stored.title = metadata.title
            stored.fileSize = Int64(metadata.fileSize)
            stored.createdAt = metadata.createdAt
            stored.cloudRecordName = metadata.cloudRecordName
            stored.pdfData = data

            try self.backgroundContext.save()
            self.backgroundContext.reset()
        }

        await fetchDocuments()

        if uploadToCloud {
            Task {
                await self.uploadToCloud(metadata: metadata, data: data)
            }
        }

        return metadata
    }

    func fetchDocuments() async {
        let request = NSFetchRequest<StoredDocument>(entityName: "StoredDocument")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

        do {
            let results = try container.viewContext.fetch(request)
            documents = results.map { DocumentMetadata(entity: $0) }
        } catch {
#if DEBUG
            print("Fetch documents failed: \(error.localizedDescription)")
#endif
        }
    }

    private func seedDemoDocumentsIfNeeded() async {
        guard documents.isEmpty else { return }

        let samples: [(title: String, body: [String])] = [
            ("Living Trust Overview", [
                "This sample document demonstrates the PDF pipeline inside DocMaker.",
                "It highlights how the generated trust summary renders when PDFKit is used on device.",
                "Feel free to replace this demo data with a real trust agreement once integrated with live services."
            ]),
            ("Estate Summary 2024", [
                "Primary grantor and spouse summary for the 2024 review cycle.",
                "Includes details about children, guardians, and key successor trustees."
            ]),
            ("Healthcare Directive", [
                "Draft healthcare directive that accompanies the living trust packet.",
                "Contains space for medical wishes, HIPAA releases, and agent designations."
            ])
        ]

        for sample in samples {
            guard let data = try? PDFComposer.makePDF(title: sample.title, sections: sample.body) else { continue }
            _ = try? await storeDocument(data: data, title: sample.title, uploadToCloud: false)
        }
    }

    private func uploadToCloud(metadata: DocumentMetadata, data: Data) async {
        let container = CKContainer.default()
        let database = container.privateCloudDatabase
        let record = CKRecord(recordType: "GeneratedDocument")
        record["title"] = metadata.title as CKRecordValue
        record["fileSize"] = metadata.fileSize as CKRecordValue
        record["createdAt"] = metadata.createdAt as CKRecordValue

        let temporaryURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(metadata.id.uuidString).pdf")

        do {
            try data.write(to: temporaryURL, options: .atomic)
            record["file"] = CKAsset(fileURL: temporaryURL)

            let savedRecord = try await database.save(record)
            try await performBackgroundWork {
                let request = NSFetchRequest<StoredDocument>(entityName: "StoredDocument")
                request.fetchLimit = 1
                request.predicate = NSPredicate(format: "id == %@", metadata.id as CVarArg)

                if let stored = try self.backgroundContext.fetch(request).first {
                    stored.cloudRecordName = savedRecord.recordID.recordName
                    try self.backgroundContext.save()
                    self.backgroundContext.reset()
                }
            }

            await fetchDocuments()
        } catch {
#if DEBUG
            print("CloudKit upload failed: \(error.localizedDescription)")
#endif
        }

        try? FileManager.default.removeItem(at: temporaryURL)
    }

    private static func makeModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        let entity = NSEntityDescription()
        entity.name = "StoredDocument"
        entity.managedObjectClassName = NSStringFromClass(StoredDocument.self)

        let id = NSAttributeDescription()
        id.name = "id"
        id.attributeType = .UUIDAttributeType
        id.isOptional = false

        let title = NSAttributeDescription()
        title.name = "title"
        title.attributeType = .stringAttributeType
        title.isOptional = false

        let fileSize = NSAttributeDescription()
        fileSize.name = "fileSize"
        fileSize.attributeType = .integer64AttributeType
        fileSize.isOptional = false

        let createdAt = NSAttributeDescription()
        createdAt.name = "createdAt"
        createdAt.attributeType = .dateAttributeType
        createdAt.isOptional = false

        let cloudRecordName = NSAttributeDescription()
        cloudRecordName.name = "cloudRecordName"
        cloudRecordName.attributeType = .stringAttributeType
        cloudRecordName.isOptional = true

        let pdfData = NSAttributeDescription()
        pdfData.name = "pdfData"
        pdfData.attributeType = .binaryDataAttributeType
        pdfData.isOptional = false

        entity.properties = [id, title, fileSize, createdAt, cloudRecordName, pdfData]

        model.entities = [entity]
        return model
    }
}

extension DocumentStorage {
    private func performBackgroundWork(_ work: @escaping () throws -> Void) async throws {
        try await withCheckedThrowingContinuation { continuation in
            backgroundContext.perform {
                do {
                    try work()
                    continuation.resume(returning: ())
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

@objc(StoredDocument)
final class StoredDocument: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var title: String
    @NSManaged var fileSize: Int64
    @NSManaged var createdAt: Date
    @NSManaged var cloudRecordName: String?
    @NSManaged var pdfData: Data
}

struct DocumentMetadata: Identifiable, Hashable {
    let id: UUID
    var title: String
    var fileSize: Int
    var createdAt: Date
    var cloudRecordName: String?

    init(id: UUID = UUID(), title: String, fileSize: Int, createdAt: Date, cloudRecordName: String? = nil) {
        self.id = id
        self.title = title
        self.fileSize = fileSize
        self.createdAt = createdAt
        self.cloudRecordName = cloudRecordName
    }

    init(entity: StoredDocument) {
        self.id = entity.id
        self.title = entity.title
        self.fileSize = Int(entity.fileSize)
        self.createdAt = entity.createdAt
        self.cloudRecordName = entity.cloudRecordName
    }

    var formattedSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(fileSize))
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: createdAt)
    }

    var cloudStatusDescription: String {
        if cloudRecordName == nil {
            return "Local only"
        }
        return "Synced"
    }
}
