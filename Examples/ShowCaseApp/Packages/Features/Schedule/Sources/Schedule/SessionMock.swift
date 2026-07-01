import Foundation

public struct Session: Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let abstract: String
    public let time: String
    public let room: String
    public let speakerName: String
    public let speakerId: String
    public let category: String

    public init(id: String, title: String, abstract: String, time: String, room: String, speakerName: String, speakerId: String, category: String) {
        self.id = id
        self.title = title
        self.abstract = abstract
        self.time = time
        self.room = room
        self.speakerName = speakerName
        self.speakerId = speakerId
        self.category = category
    }
}

public enum SessionMock {
    public static let sessions: [Session] = [
        Session(
            id: "101",
            title: "Keynote",
            abstract: "Welcome to WWDC 2026. Discover the future of iOS.",
            time: "09:00 - 11:00",
            room: "Steve Jobs Theater",
            speakerName: "Marcus Sterling",
            speakerId: "s1",
            category: "General"
        ),
        Session(
            id: "102",
            title: "What's new in SwiftUI",
            abstract: "A deep dive into the latest SwiftUI features and APIs. Learn how to build more dynamic apps.",
            time: "11:30 - 12:30",
            room: "Hall A",
            speakerName: "David Chen",
            speakerId: "s3",
            category: "UI Frameworks"
        ),
        Session(
            id: "103",
            title: "Advanced NavigationKit",
            abstract: "Build massive, modular iOS apps using NavigationKit. Handle deep linking and modular state with ease.",
            time: "14:00 - 15:00",
            room: "Hall B",
            speakerName: "Elena Rostova",
            speakerId: "s2",
            category: "Architecture"
        ),
        Session(
            id: "104",
            title: "Mastering Swift 6 Concurrency",
            abstract: "Learn how to adopt Swift 6 strict concurrency checks to make your code bulletproof.",
            time: "15:30 - 16:30",
            room: "Hall C",
            speakerName: "Sarah Jenkins",
            speakerId: "s4",
            category: "Swift"
        ),
        Session(
            id: "105",
            title: "Design Systems in iOS",
            abstract: "Building reusable component libraries that scale across multiple platforms.",
            time: "09:00 - 10:00",
            room: "Room 1",
            speakerName: "Liam O'Connor",
            speakerId: "s5",
            category: "Design"
        ),
        Session(
            id: "106",
            title: "The Magic of Core Data & SwiftData",
            abstract: "Transitioning from Core Data to SwiftData safely and effectively.",
            time: "10:30 - 11:30",
            room: "Room 2",
            speakerName: "Priya Patel",
            speakerId: "s6",
            category: "Data"
        ),
        Session(
            id: "107",
            title: "Server-Side Swift with Vapor",
            abstract: "Bring your Swift skills to the backend. Deploy high-performance servers.",
            time: "13:00 - 14:00",
            room: "Room 3",
            speakerName: "James Wilson",
            speakerId: "s7",
            category: "Backend"
        ),
        Session(
            id: "108",
            title: "Accessibility Matters",
            abstract: "How to audit and fix accessibility issues so your app reaches everyone.",
            time: "14:30 - 15:30",
            room: "Room 1",
            speakerName: "Alex Rodriguez",
            speakerId: "s8",
            category: "General"
        ),
        Session(
            id: "109",
            title: "App Intents and Siri Shortcuts",
            abstract: "Integrate your app deeply into iOS with the new App Intents framework.",
            time: "16:00 - 17:00",
            room: "Room 2",
            speakerName: "Yuki Tanaka",
            speakerId: "s9",
            category: "Integration"
        ),
        Session(
            id: "110",
            title: "Building AR Experiences",
            abstract: "Harness RealityKit and visionOS to bring 3D elements into the real world.",
            time: "10:00 - 11:00",
            room: "Hall B",
            speakerName: "Sophia Martinez",
            speakerId: "s10",
            category: "AR/VR"
        ),
        Session(
            id: "111",
            title: "Combine to Async/Await",
            abstract: "Refactoring legacy Combine pipelines into clean Async/Await sequences.",
            time: "11:30 - 12:30",
            room: "Room 3",
            speakerName: "Michael Chang",
            speakerId: "s11",
            category: "Swift"
        ),
        Session(
            id: "112",
            title: "Animations that Wow",
            abstract: "Going beyond implicit animations. Mastering phase animators and keyframes.",
            time: "15:00 - 16:00",
            room: "Hall A",
            speakerName: "Emma Thompson",
            speakerId: "s12",
            category: "UI Frameworks"
        )
    ]
}
