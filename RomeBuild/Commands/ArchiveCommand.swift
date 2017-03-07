import Foundation
import RomeKit

struct ArchiveCommand {

    func upload(productName: String, revision: String, platforms: String?) {

        print("Archiving \(productName)")

        let status = Carthage(["archive"])

        Helpers().uploadAsset(productName, revision: revision, filePath: getFrameworkPath(status))
        print("Upload complete")

    }

}