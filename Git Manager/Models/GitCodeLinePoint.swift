import SwiftUI

struct GitCodeLinePoint: Identifiable, Hashable {
    let fullHash: String
    let shortHash: String
    let subject: String
    let date: Date
    let delta: Int
    let totalLines: Int

    var id: String { fullHash }
}
