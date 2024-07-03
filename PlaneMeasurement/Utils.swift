//
//  Utils.swift
//  PlaneMeasurement
//
//  Created by Adwith Mukherjee on 6/24/24.
//

import Foundation
import UIKit
import VideoToolbox
import ARKit

/// Get current time in string.
func getTimeStr() -> String {
    let df = DateFormatter()
    df.dateFormat = "yyyy-MM-dd_hhmmss"
    return df.string(from: Date())
}

/// Save file to a directory.
func saveFile(content: String, filename: String, folder: String) async throws -> () {
    print("Save file to \(folder)/\(filename)")
    let url = getDocumentsDirectory().appendingPathComponent(folder, isDirectory: true).appendingPathComponent(filename)
    try content.write(to: url, atomically: true, encoding: .utf8)
}

/// Save jpeg to a directory.
func savePic(pic: UIImage?, filename: String, folder: String) async throws -> () {
    print("Attempting to save picture to \(folder)/\(filename)")
    
    // Check if the image is valid
    guard let pic = pic else {
        throw NSError(domain: "SavePicError", code: 3, userInfo: [NSLocalizedDescriptionKey: "Invalid image: Image is nil"])
    }
    
    let fileManager = FileManager.default
    let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    
    guard let documentsPath = documentsPath else {
        throw NSError(domain: "SavePicError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to access documents directory"])
    }
    
    if !fileManager.isWritableFile(atPath: documentsPath.path) {
        throw NSError(domain: "SavePicError", code: 1, userInfo: [NSLocalizedDescriptionKey: "No write permission for documents directory"])
    }
    
    let folderURL = documentsPath.appendingPathComponent(folder, isDirectory: true)
    let fileURL = folderURL.appendingPathComponent(filename)
    
    // Create the directory if it doesn't exist
    try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
    
    // Use a reasonable compression quality (e.g., 0.8 for good quality)
    guard let data = pic.jpegData(compressionQuality: 0.8) else {
        throw NSError(domain: "SavePicError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to create JPEG data"])
    }
    
    // Check available storage space
    let fileSize = Int64(data.count)
    do {
        let resourceValues = try folderURL.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
        guard let freeSpace = resourceValues.volumeAvailableCapacityForImportantUsage else {
            throw NSError(domain: "SavePicError", code: 4, userInfo: [NSLocalizedDescriptionKey: "Unable to determine available storage space"])
        }
        
        if freeSpace < fileSize {
            throw NSError(domain: "SavePicError", code: 5, userInfo: [NSLocalizedDescriptionKey: "Insufficient storage space"])
        }
    } catch {
        throw NSError(domain: "SavePicError", code: 4, userInfo: [NSLocalizedDescriptionKey: "Error checking available storage space: \(error.localizedDescription)"])
    }
    
    try data.write(to: fileURL)
    print("Image saved successfully to \(fileURL.path)")
}

/// Transform cvPixelBuffer of datatype <T> to a 2D array map.
func cvPixelBuffer2Map<T : Numeric>(rawDepth: CVPixelBuffer) async -> [[T]] {
    CVPixelBufferLockBaseAddress(rawDepth, CVPixelBufferLockFlags(rawValue: 0))
    let addr = CVPixelBufferGetBaseAddress(rawDepth)
    let height = CVPixelBufferGetHeight(rawDepth)
    let width = CVPixelBufferGetWidth(rawDepth)

    let TBuffer = unsafeBitCast(addr, to: UnsafeMutablePointer<T>.self)

    var TMap : [[T]] = Array(repeating: Array(repeating: T(exactly: 0)!, count: width), count: height)

    for row in 0...(height - 1){
        for col in 0...(width - 1){
            TMap[row][col] = TBuffer[row * width + col]
        }
    }
    CVPixelBufferUnlockBaseAddress(rawDepth, CVPixelBufferLockFlags(rawValue: 0))
    return TMap
}

/// Transform cvPixelBuffer to a UIImage.
func cvPixelBuffer2UIImage(pixelBuffer: CVPixelBuffer) -> UIImage {
    let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
    return UIImage(ciImage: ciImage)
}

func getDocumentsDirectory() -> URL {
    // find all possible documents directories for this user
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

    // just send back the first one, which ought to be the only one
    return paths[0]
}

func createDirectory(folder: String) {
    let path = getDocumentsDirectory().appendingPathComponent(folder)
    do
    {
        try FileManager.default.createDirectory(at: path, withIntermediateDirectories: true)
    }
    catch let error as NSError
    {
        print("Unable to create directory \(error.debugDescription)")
    }

}

/// https://stackoverflow.com/questions/63661474/how-can-i-encode-an-array-of-simd-float4x4-elements-in-swift-convert-simd-float
extension simd_float4x4: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        try self.init(container.decode([SIMD4<Float>].self))
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode([columns.0, columns.1, columns.2, columns.3])
    }
}


extension simd_float3x3: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        try self.init(container.decode([SIMD3<Float>].self))
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode([columns.0, columns.1, columns.2])
    }
}

/// Send task start/finish messages.
protocol TaskDelegate: AnyObject {
    func didStartTask()
    func didFinishTask()
}

/// Deep copy CVPixelBuffer for depth data
/// https://stackoverflow.com/questions/65868215/deep-copy-cvpixelbuffer-for-depth-data-in-swift
func duplicatePixelBuffer(input: CVPixelBuffer) -> CVPixelBuffer {
    var copyOut: CVPixelBuffer?
    let bufferWidth = CVPixelBufferGetWidth(input)
    let bufferHeight = CVPixelBufferGetHeight(input)
    let bytesPerRow = CVPixelBufferGetBytesPerRow(input)
    let bufferFormat = CVPixelBufferGetPixelFormatType(input)

    _ = CVPixelBufferCreate(kCFAllocatorDefault, bufferWidth, bufferHeight, bufferFormat, CVBufferGetAttachments(input, CVAttachmentMode.shouldPropagate), &copyOut)
    let output = copyOut!
    // Lock the depth map base address before accessing it
    CVPixelBufferLockBaseAddress(input, CVPixelBufferLockFlags.readOnly)
    CVPixelBufferLockBaseAddress(output, CVPixelBufferLockFlags(rawValue: 0))
    let baseAddress = CVPixelBufferGetBaseAddress(input)
    let baseAddressCopy = CVPixelBufferGetBaseAddress(output)
    memcpy(baseAddressCopy, baseAddress, bufferHeight * bytesPerRow)

    // Unlock the base address when finished accessing the buffer
    CVPixelBufferUnlockBaseAddress(input, CVPixelBufferLockFlags.readOnly)
    CVPixelBufferUnlockBaseAddress(output, CVPixelBufferLockFlags(rawValue: 0))
    return output
}
