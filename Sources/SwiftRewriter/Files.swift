#if os(Linux)
import Glibc
#endif

import Foundation

/// Finds all files in a given directory recursively, optionaly specifying include
/// and exclude patterns to fine-grain the results.
///
/// - Parameters:
///   - directoryPath: Base directory to search files in.
///   - includePattern: An optional pattern that when specified only includes
/// (full) file patterns that match a specified pattern.
///   - excludePattern: An optional pattern that when specified omits files
/// matching the pattern. Takes priority over `includePattern`.
/// - Returns: The full file URL for each file found satisfying the patterns specified.
func filesAt(path directoryPath: String, includePattern: String? = nil, excludePattern: String? = nil) -> [URL] {
    let fnflags: Int32
    #if os(macOS)
    fnflags = FNM_CASEFOLD
    #else
    fnflags = 0
    #endif
    
    let fileManager = FileManager.default
    guard var objcFiles = fileManager.enumerator(atPath: directoryPath)?.compactMap({ $0 as? String }) else {
        return []
    }
    
    // Inclusions
    if let includePattern = includePattern {
        objcFiles = objcFiles.filter { path in
            fnmatch(includePattern, path, fnflags) == 0
        }
    }
    // Exclusions
    if let excludePattern = excludePattern {
        objcFiles = objcFiles.filter { path in
            fnmatch(excludePattern, path, fnflags) != 0
        }
    }
    
    return
        objcFiles
            // Sort files, for convenience of better conveying progress to user
            .sorted { (s1: String, s2: String) -> Bool in
                let name1 = (s1 as NSString).lastPathComponent
                let name2 = (s2 as NSString).lastPathComponent
            
                return name1.compare(name2, options: .numeric) == .orderedAscending
            }
            // Map full path
            .map { (path: String) -> String in
                return (directoryPath as NSString).appendingPathComponent(path)
            }
            // Convert to URLs
            .map { (path: String) -> URL in
                return URL(fileURLWithPath: path)
            }
}
