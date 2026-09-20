import Foundation

struct GitCodeLinePoint: Identifiable, Hashable, Codable {
    let fullHash: String
    let shortHash: String
    let subject: String
    let date: Date
    let delta: Int
    let totalLines: Int
    
    var id: String { fullHash }
}
