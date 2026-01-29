import Foundation

struct GitRemoteURLBuilder {
    enum Provider {
        case github, gitlab, bitbucket, other
    }

    struct RemoteInfo {
        let host: String
        let repoPath: String
        let webBase: String
        let provider: Provider
    }

    static func pullRequestURL(remote: String, base: String, head: String) -> URL? {
        guard let info = normalize(remote) else { return nil }

        switch info.provider {
        case .github:
            let baseEncoded = encodePathComponent(base)
            let headEncoded = encodePathComponent(head)
            var components = URLComponents(string: "\(info.webBase)/compare/\(baseEncoded)...\(headEncoded)")
            components?.queryItems = [URLQueryItem(name: "expand", value: "1")]
            return components?.url
        case .gitlab:
            var components = URLComponents(string: "\(info.webBase)/-/merge_requests/new")
            components?.queryItems = [
                URLQueryItem(name: "merge_request[source_branch]", value: head),
                URLQueryItem(name: "merge_request[target_branch]", value: base)
            ]
            return components?.url
        case .bitbucket:
            var components = URLComponents(string: "\(info.webBase)/pull-requests/new")
            components?.queryItems = [
                URLQueryItem(name: "source", value: head),
                URLQueryItem(name: "dest", value: base)
            ]
            return components?.url
        case .other:
            return nil
        }
    }

    static func issueURL(remote: String, issueNumber: String) -> URL? {
        guard let info = normalize(remote) else { return nil }
        let digits = issueNumber.filter(\.isNumber)
        guard !digits.isEmpty else { return nil }

        switch info.provider {
        case .github:
            return URL(string: "\(info.webBase)/issues/\(digits)")
        case .gitlab:
            return URL(string: "\(info.webBase)/-/issues/\(digits)")
        case .bitbucket:
            return URL(string: "\(info.webBase)/issues/\(digits)")
        case .other:
            return nil
        }
    }

    private static func normalize(_ remote: String) -> RemoteInfo? {
        let trimmed = remote.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let host: String
        var path: String

        if let url = URL(string: trimmed), let urlHost = url.host {
            host = urlHost
            path = url.path
        } else if let scp = parseScp(trimmed) {
            host = scp.host
            path = scp.path
        } else {
            return nil
        }

        path = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        if path.hasSuffix(".git") {
            path.removeLast(4)
        }

        guard !path.isEmpty else { return nil }

        let webBase = "https://\(host)/\(path)"
        return RemoteInfo(
            host: host,
            repoPath: path,
            webBase: webBase,
            provider: provider(for: host)
        )
    }

    private static func provider(for host: String) -> Provider {
        let lowercased = host.lowercased()
        if lowercased.contains("github") { return .github }
        if lowercased.contains("gitlab") { return .gitlab }
        if lowercased.contains("bitbucket") { return .bitbucket }
        return .other
    }

    private static func parseScp(_ remote: String) -> (host: String, path: String)? {
        guard let atIndex = remote.firstIndex(of: "@") else { return nil }
        let afterAt = remote[remote.index(after: atIndex)...]
        guard let colonIndex = afterAt.firstIndex(of: ":") else { return nil }
        let host = String(afterAt[..<colonIndex])
        let path = String(afterAt[afterAt.index(after: colonIndex)...])
        guard !host.isEmpty, !path.isEmpty else { return nil }
        return (host: host, path: "/" + path)
    }

    private static func encodePathComponent(_ value: String) -> String {
        let allowed = CharacterSet.urlPathAllowed.subtracting(CharacterSet(charactersIn: "/"))
        return value.addingPercentEncoding(withAllowedCharacters: allowed) ?? value
    }
}
