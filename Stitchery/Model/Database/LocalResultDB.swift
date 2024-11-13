//
//  LocalResultDB.swift
//  Stitchery
//
//  Created by Ethan Thomas on 11/12/24.
//

import Foundation

protocol LocalResultDB {
    func createLocalResult(_ result: GoogleMapsLocalResults.LocalResults) async throws -> GoogleMapsLocalResults.LocalResults
    func retrieveLocalResult() async throws -> GoogleMapsLocalResults.LocalResults
    func deleteLocalResult() async throws -> GoogleMapsLocalResults.LocalResults?
}
