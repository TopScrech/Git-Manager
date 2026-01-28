import SwiftUI

struct RepositoryScanner {
    static func findRepositories(in rootURL: URL) -> [URL] {
        let manager = FileManager.default
        var repositories: [URL] = []
        var stack: [URL] = [rootURL]

        while let current = stack.popLast() {
            if isRepository(at: current, manager: manager) {
                repositories.append(current)
                continue
            }

            guard let contents = try? manager.contentsOfDirectory(
                at: current,
                includingPropertiesForKeys: [.isDirectoryKey, .isSymbolicLinkKey],
                options: [.skipsHiddenFiles, .skipsPackageDescendants]
            ) else { continue }

            for url in contents {
                let values = try? url.resourceValues(forKeys: [.isDirectoryKey, .isSymbolicLinkKey])
                guard values?.isDirectory == true else { continue }
                if values?.isSymbolicLink == true { continue }
                stack.append(url)
            }
        }

        return repositories
    }

    static func isRepository(at url: URL, manager: FileManager = .default) -> Bool {
        let gitURL = url.appendingPathComponent(".git")
        return manager.fileExists(atPath: gitURL.path)
    }
}
