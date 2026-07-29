import Foundation

public struct SidebarColumnWidth {
    public let min: CGFloat
    public let ideal: CGFloat
    public let max: CGFloat
    
    public init(min: CGFloat, ideal: CGFloat, max: CGFloat) {
        self.min = min
        self.ideal = ideal
        self.max = max
    }
    
    public init (width: CGFloat) {
        self.min = width
        self.ideal = width
        self.max = width
    }
}
