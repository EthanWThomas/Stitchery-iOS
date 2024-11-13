//
//  KeyConstant.swift
//  Stitchery
//
//  Created by Ethan Thomas on 11/5/24.
//

import Foundation

enum KeyConstant {
    static func loadAPIKey() async throws {
        let request = NSBundleResourceRequest(tags: ["APIKey"])
        try await request.beginAccessingResources()
        
        let url = Bundle.main.url(forResource: "APIKey", withExtension: "json")!
        let data = try Data(contentsOf: url)
        
        APIKey.storage = try JSONDecoder().decode([String: String].self, from: data)
        
        request.endAccessingResources()
    }
    
    enum APIKey {
        static fileprivate(set) var storage = [String: String]()
        
        static var myAPIKey: String {
            guard let apiKey = storage["api_key"] else {
                fatalError("API key not found in APIKey.json. Please ensure it's included and has the correct key name.")
            }
            return apiKey
        }
    }
    
//    enum APIKey {
//        static fileprivate(set) var storage = [String: String]()
//        
//        static var myAPIKey: String { storage["api_key"] ?? "" }
//    }
    
    enum APIKeyError: Error {
        case missingFile
    }
}
