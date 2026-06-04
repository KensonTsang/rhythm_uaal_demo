//
//  JsonLoader.swift
//  NativeiOSApp
//

import Foundation

struct MessageJson: Codable {
    let id: String
    let chunkIndex: Int
    let totalChunks: Int
    let data: String
}

@objc class JsonLoader: NSObject {

    @objc(loadJsonNamed:)
    static func loadJson(named message: String) -> String? {
        let fileName: String
        switch message {
        case "json1":
            fileName = "json1_1MB"
        default:
            NSLog("[JsonLoader] Unknown json request: %@", message)
            return nil
        }

        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            NSLog("[JsonLoader] File not found: %@.json", fileName)
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let jsonString = String(data: data, encoding: .utf8)
            NSLog("[JsonLoader] Loaded %@.json (%d bytes)", fileName, data.count)
            return jsonString
        } catch {
            NSLog("[JsonLoader] Failed to load %@.json: %@", fileName, error.localizedDescription)
            return nil
        }
    }

    @objc(buildMessageJsonWithId:chunkIndex:totalChunks:data:)
    static func buildMessageJson(id: String, chunkIndex: Int, totalChunks: Int, data: String) -> String? {
        let msg = MessageJson(id: id, chunkIndex: chunkIndex, totalChunks: totalChunks, data: data)
        do {
            let jsonData = try JSONEncoder().encode(msg)
            return String(data: jsonData, encoding: .utf8)
        } catch {
            NSLog("[JsonLoader] Failed to encode MessageJson: %@", error.localizedDescription)
            return nil
        }
    }
}
