import Combine
import SwiftUI

@MainActor
final class RepoStore: ObservableObject {
    private let selectedFolderKey = "selectedFolderPath"
    private let selectedFolderBookmarkKey = "selectedFolderBookmark"
    private var securityScopedFolder: URL?

    @Published private(set) var repositories: [GitRepository] = []
    @Published private(set) var isScanning = false
    @Published private(set) var selectedFolder: URL?

    init() {
        restoreSelectedFolder()
    }

    func scan(_ folder: URL) {
        isScanning = true

        Task {
            let repos = await Task.detached(priority: .userInitiated) {
                await RepoService.loadRepositories(in: folder)
            }.value
            withAnimation(.easeOut(duration: 0.35)) {
                repositories = repos
                isScanning = false
            }
        }
    }

    func refresh() {
        guard let folder = selectedFolder else { return }
        scan(folder)
    }

    func selectFolder(_ folder: URL?) {
        stopAccessingSecurityScopedFolder()

        guard let folder else {
            selectedFolder = nil
            persistSelectedFolder(nil)
            return
        }

        _ = folder.startAccessingSecurityScopedResource()
        securityScopedFolder = folder
        selectedFolder = folder
        persistSelectedFolder(folder)
    }

    private func restoreSelectedFolder() {
        if let bookmarkData = UserDefaults.standard.data(forKey: selectedFolderBookmarkKey) {
            do {
                var isStale = false
                let url = try URL(
                    resolvingBookmarkData: bookmarkData,
                    options: [.withSecurityScope],
                    bookmarkDataIsStale: &isStale
                )
                _ = url.startAccessingSecurityScopedResource()
                securityScopedFolder = url
                selectedFolder = url
                if isStale {
                    persistSelectedFolder(url)
                }
                scan(url)
                return
            } catch {
                persistSelectedFolder(nil)
            }
        }

        if let path = UserDefaults.standard.string(forKey: selectedFolderKey) {
            let url = URL(fileURLWithPath: path)
            if FileManager.default.fileExists(atPath: url.path) {
                selectedFolder = url
                scan(url)
            } else {
                persistSelectedFolder(nil)
            }
        }
    }

    private func persistSelectedFolder(_ folder: URL?) {
        guard let folder else {
            UserDefaults.standard.removeObject(forKey: selectedFolderKey)
            UserDefaults.standard.removeObject(forKey: selectedFolderBookmarkKey)
            return
        }

        UserDefaults.standard.set(folder.path, forKey: selectedFolderKey)

        do {
            let bookmarkData = try folder.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            UserDefaults.standard.set(bookmarkData, forKey: selectedFolderBookmarkKey)
        } catch {
            UserDefaults.standard.removeObject(forKey: selectedFolderBookmarkKey)
        }
    }

    private func stopAccessingSecurityScopedFolder() {
        guard let securityScopedFolder else { return }
        securityScopedFolder.stopAccessingSecurityScopedResource()
        self.securityScopedFolder = nil
    }
}
