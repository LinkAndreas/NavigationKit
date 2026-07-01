import Foundation

public struct Speaker: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let role: String
    public let company: String
    public let bio: String
    public let imageName: String
    public let badges: [String]

    public init(id: String, name: String, role: String, company: String, bio: String, imageName: String, badges: [String] = []) {
        self.id = id
        self.name = name
        self.role = role
        self.company = company
        self.bio = bio
        self.imageName = imageName
        self.badges = badges
    }
}

public enum SpeakerMock {
    public static let speakersBundle = Bundle.module

    public static let speakers: [Speaker] = [
        Speaker(
            id: "s1",
            name: "Marcus Sterling",
            role: "SVP Software Engineering",
            company: "TechNova",
            bio: "Known for his energetic presentations, Marcus leads the mobile OS engineering teams.",
            imageName: "avatar_1",
            badges: ["Keynote", "TechNova"]
        ),
        Speaker(
            id: "s2",
            name: "Elena Rostova",
            role: "Creator of AlphaLang",
            company: "Modular Tech",
            bio: "The visionary behind next-gen compiler infrastructure projects.",
            imageName: "avatar_2",
            badges: ["Architecture", "AlphaLang"]
        ),
        Speaker(
            id: "s3",
            name: "David Chen",
            role: "Educator",
            company: "Code Masterclass",
            bio: "Dedicated to helping everyone learn modern app development.",
            imageName: "avatar_3",
            badges: ["UI Frameworks", "AlphaLang"]
        ),
        Speaker(
            id: "s4",
            name: "Sarah Jenkins",
            role: "Senior Engineer",
            company: "TechNova",
            bio: "Expert in strict concurrency and language evolution.",
            imageName: "avatar_4",
            badges: ["AlphaLang"]
        ),
        Speaker(
            id: "s5",
            name: "Liam O'Connor",
            role: "Designer & Developer",
            company: "DesignFlow",
            bio: "Teaching designers how to code, and coders how to design.",
            imageName: "avatar_5",
            badges: ["Design", "UI Frameworks"]
        ),
        Speaker(
            id: "s6",
            name: "Priya Patel",
            role: "Author & Developer",
            company: "Freelance",
            bio: "Author of Practical Database Management and Reactive Pipelines.",
            imageName: "avatar_6",
            badges: ["Data", "AlphaLang"]
        ),
        Speaker(
            id: "s7",
            name: "James Wilson",
            role: "Core Team",
            company: "CloudSurge",
            bio: "Bringing mobile languages to high-performance servers.",
            imageName: "avatar_7",
            badges: ["Backend", "AlphaLang"]
        ),
        Speaker(
            id: "s8",
            name: "Alex Rodriguez",
            role: "Mobile Developer",
            company: "Streamify",
            bio: "Passionate about making apps accessible for everyone.",
            imageName: "avatar_8",
            badges: ["General", "Design"]
        ),
        Speaker(
            id: "s9",
            name: "Yuki Tanaka",
            role: "Creator",
            company: "Weekly Code",
            bio: "Podcaster and writer of weekly technical articles.",
            imageName: "avatar_9",
            badges: ["AlphaLang", "Integration"]
        ),
        Speaker(
            id: "s10",
            name: "Sophia Martinez",
            role: "Developer",
            company: "Future AR",
            bio: "Exploring the intersections of tech and human experience.",
            imageName: "avatar_10",
            badges: ["AR/VR"]
        ),
        Speaker(
            id: "s11",
            name: "Michael Chang",
            role: "Engineer",
            company: "PixelPerfect",
            bio: "Loves to share development tips through video tutorials.",
            imageName: "avatar_11",
            badges: ["AlphaLang"]
        ),
        Speaker(
            id: "s12",
            name: "Emma Thompson",
            role: "UI/UX Developer",
            company: "VideoTube",
            bio: "Creating mind-blowing animations and reusable UI components.",
            imageName: "avatar_12",
            badges: ["UI Frameworks", "Design"]
        ),
        Speaker(
            id: "s13",
            name: "Oliver Smith",
            role: "Author",
            company: "Independent",
            bio: "Prolific author and contributor to language evolution processes.",
            imageName: "avatar_13",
            badges: ["Architecture", "AlphaLang"]
        )
    ]
}
