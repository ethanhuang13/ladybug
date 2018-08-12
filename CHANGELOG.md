# Ladybug Changelog

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]
- Scroll to top when loading another radar #19
- Radar title in the lists should show full text with multiple lines #21

## [1.2.0(11)] - 2018-07-26
### Added
- [Suggestion] Add case-sensitive warning on import from Open Radar #15
- Support radar:// links #16
- Support Handoff to webpage #17
- UITableView.cellLayoutMarginsFollowReadableWidth set true #18
- Support open links from radar description #14

## [1.1.1(10)] - 2018-07-18
### Fixed
- Fix push DetailViewController not in main thread

---
## [1.1.0(9)] - 2018-07-14
### Added
- Native View 3D Touch Peek & Previewing Actions #12

## [1.1.0(8)] - 2018-07-14
### Added
- Increase number of imported radars by fetch the next batch #6 Idea thanks to @futuretap
- Improve paste email to the import textField #10
- Sorting Options #3 #7
- When importing JSON, let user select to merge or replace #8
- List filtering #9
- Native Radar Detail View #11

---
## [1.0.0(7)] - 2018-07-09
### Added
- User agent in Open Radar API request #4
- Open Radar user API key #5

### Changed
- Combine TableViewViewModel and TableViewDataSourceDelegate

## [1.0.0(6)] - 2018-07-07
### Hotfix
- Handle rdar://problem/number

## [1.0.0(5)] - 2018-07-06
### Added
- Backup & Restore as JSON
- More tests

### Changed
- Rename RadarID to RadarNumber
- Rewrite how to save Radars. Combine Radar, Radar Number and Radar Metadata to a JSON file
- Refactor RadarNumber, URLParsers and Builders

## [0.4(4)] - 2018-06-30
### Added
- 3D Touch Peek & Pop for lists
- Manually input to add radar
- Detect radar number in clipboard

## [0.3(3)] - 2018-06-29
### Added
- Retrive radar metadata from Open Radar for lists
- Export radars
- Import radars from Open Radar

## [0.2(2)] - 2018-06-26
### Added
- RadarCollection for radars local CRUD (temporarily use Codable + UserDefaults)
- History view
- Bookmarks view

### Changed
- Recents changes to History
- Favorites changes to Bookmarks

## [0.1(1)] - 2018-06-23
### Added
- Radar model, RadarURLParser, RadarURLBuilder protocols, implementation, and tests
- Basic UI architecture
- BriskRadar and tests
- Localization
- Present in SFSafariViewController
- Use Main.storyboard as launch screen file
- RadarOption and BrowserOption in settings
- App Store, developer's Twitter, and GitHub links
- Feedback email composer
- App icon
- Theme
