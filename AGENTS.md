# Repository Guidelines

This is a macOS SwiftUI app managed in Xcode and organized by feature folders and shared services

## Project Structure & Module Organization
- App entry point: `Git Manager/App/GitManagerApp.swift`
- Views: `Git Manager/Views/` with subfolders like `Content/`, `RepoDetail/`, `RepoList/`, `Shared/`
- Models: `Git Manager/Models/` for data types like `GitRepository` and `GitCommit`
- Services: `Git Manager/Services/` for file access, scanning, and Git interactions
- Theme and design tokens: `Git Manager/Theme/`
- Assets: `Git Manager/Assets.xcassets/`

## Build, Test, and Development Commands
- Open in Xcode: `open "Git Manager.xcodeproj"` to build and run the shared scheme
- CLI build: `xcodebuild -scheme "Git Manager" -configuration Debug build` for a local build
- No test targets are currently in the project, so there are no test commands to run

## Testing Guidelines
- No test framework or coverage targets are defined yet
- If tests are added, keep names aligned with their subject, for example `RepoStoreTests`

## Commit & Pull Request Guidelines
- Link issues or tasks when available

## Security & Configuration
- The app uses security scoped bookmarks for folder access, prefer that pattern when adding file system features
