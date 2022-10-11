import Foundation
import Sh

func generateProject(config: Config) throws {
  try sh(.terminal,
         "mint run -m Mintfile yonaskolb/Xcodegen xcodegen -s xcodegen.yml",
         environment: [
          "FQAUTH_BUNDLE_ID": config.bundleID,
          "FQAUTH_DEVELOPMENT_TEAM": config.developmentTeam,
         ])
}
