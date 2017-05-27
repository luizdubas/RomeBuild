import Foundation
import RomeKit

struct UploadCommand {
    
    func upload(platforms: String?) {
        
        if !Cartfile().exists() {
            Carthage(["update", "--no-build"])
        } else {
            Carthage(["checkout"])
        }
        
        var dependenciesToBuild = [String:String]()
        let dependencies = Cartfile().load()
        
        for (name, revision) in dependencies {
            print("")
            print(name, revision)
            if Rome().getLatestByRevison(name, revision: revision) == nil {
                dependenciesToBuild[name] = revision
            }
        }
        
        let dependenciesToUploadArray = Array(dependenciesToBuild.keys.map { $0 })
        
        if dependenciesToUploadArray.count > 0 {
            for dependency in dependenciesToUploadArray {
                let dependencyPath = "\(Environment().currentDirectory()!)/Carthage/Checkouts/\(dependency)"
                let carthageBuildPath = "Carthage/Checkouts/\(dependency)"
                
                print("Trying to pre archive \(dependency)")
                var status = Carthage(["archive", "--project-directory", carthageBuildPath])
                if status.status != 0 {
                    print("Couldn't find framework\nCheckout project dependency \(dependency)")
                    Carthage(["checkout", dependency])
                    
                    print("Checkout inner dependencies for \(dependency)")
                    Carthage(["bootstrap", "--no-build", "--project-directory", dependencyPath])
                    
                    print("Building \(dependency) for archive")
                    
                    var buildArchive = ["build", "--no-skip-current", "--project-directory", dependencyPath]
                    
                    if let buildPlatforms = platforms {
                        buildArchive.append("--platform")
                        buildArchive.append(buildPlatforms)
                    }
                    
                    Carthage(buildArchive)
                    status = Carthage(["archive", "--output", Environment().currentDirectory()!], path: dependencyPath)
                }
                Helpers().uploadAsset(dependency, revision: dependenciesToBuild[dependency]!, filePath: getFrameworkPath(status))
            }
        }
        
        print("Upload complete")
        
    }
    
}
