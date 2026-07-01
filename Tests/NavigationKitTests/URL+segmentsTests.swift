import Foundation
import Testing
@testable import NavigationKit

@Test
func extractsURLSegmentsCorrectly() async throws {
    let url1 = URL(string: "myapp://profile/settings")!
    #expect(url1.segments == ["profile", "settings"])
    
    let url2 = URL(string: "myapp://home/")!
    #expect(url2.segments == ["home"])
    
    let url3 = URL(string: "myapp://")!
    #expect(url3.segments == [])
    
    let url4 = URL(string: "https://example.com/a/b/c/")!
    #expect(url4.segments == ["example.com", "a", "b", "c"])
}
