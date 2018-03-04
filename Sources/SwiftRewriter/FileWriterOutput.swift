import Foundation
import SwiftRewriterLib

class FileDiskWriterOutput: WriterOutput {
    func createFile(path: String) -> FileOutput {
        return FileOutputImpl(path: path)
    }
}

class FileOutputImpl: FileOutput {
    let path: String
    let file: FileOutputTarget
    
    init(path: String) {
        if !FileManager.default.fileExists(atPath: path) {
            FileManager.default.createFile(atPath: path, contents: nil)
        } else {
            
        }
        
        // Open output stream
        let handle = /* TODO: Deal with this force unwrap! */ FileHandle(forWritingAtPath: path)!
        handle.truncateFile(atOffset: 0)
        
        self.path = path
        file = FileOutputTarget(fileHandle: handle)
    }
    
    func close() {
        file.close()
    }
    
    func outputTarget() -> RewriterOutputTarget {
        return file
    }
}

class FileOutputTarget: RewriterOutputTarget {
    private var identDepth: Int = 0
    private var settings: RewriterOutputSettings
    var fileHandle: FileHandle
    
    var colorize: Bool = true
    
    public init(fileHandle: FileHandle, settings: RewriterOutputSettings = .defaults) {
        self.fileHandle = fileHandle
        self.settings = settings
    }
    
    func close() {
        fileHandle.closeFile()
    }
    
    func writeToFile(_ buffer: String) {
        if let data = buffer.data(using: .utf8) {
          fileHandle.write(data)
        }
    }
    
    public func output(line: String, style: TextStyle) {
        outputIdentation()
        writeToFile(line)
        outputLineFeed()
    }
    
    public func outputIdentation() {
        writeToFile(identString())
    }
    
    public func outputLineFeed() {
        writeToFile("\n")
    }
    
    public func outputInline(_ content: String, style: TextStyle) {
        writeToFile(content)
    }
    
    public func increaseIdentation() {
        identDepth += 1
    }
    
    public func decreaseIdentation() {
        identDepth -= 1
    }
    
    public func onAfterOutput() {
        
    }
    
    private func identString() -> String {
        switch settings.tabStyle {
        case .spaces(let sp):
            return String(repeating: " ", count: sp * identDepth)
        case .tabs:
            return String(repeating: "\t", count: identDepth)
        }
    }
}
