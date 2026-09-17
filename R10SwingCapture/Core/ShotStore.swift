import Foundation
import SwiftData

@MainActor
final class ShotStore {
    let container: ModelContainer

    init(inMemory: Bool = false) throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: inMemory)
        self.container = try ModelContainer(for: PracticeSession.self, ShotRecord.self, configurations: configuration)
    }

    func insert(_ object: some PersistentModel) throws {
        container.mainContext.insert(object)
        try container.mainContext.save()
    }

    func save() throws { try container.mainContext.save() }

    func sessions() throws -> [PracticeSession] {
        let descriptor = FetchDescriptor<PracticeSession>(sortBy: [SortDescriptor(\PracticeSession.startedAt, order: .reverse)])
        return try container.mainContext.fetch(descriptor)
    }

    func shots(for sessionID: UUID) throws -> [ShotRecord] {
        let predicate = #Predicate<ShotRecord> { $0.sessionID == sessionID }
        let descriptor = FetchDescriptor<ShotRecord>(predicate: predicate, sortBy: [SortDescriptor(\ShotRecord.shotNumber)])
        return try container.mainContext.fetch(descriptor)
    }
}
