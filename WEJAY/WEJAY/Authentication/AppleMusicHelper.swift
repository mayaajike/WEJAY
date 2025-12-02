//
//  AppleMusicHelper.swift
//  WEJAY
//
//  Created by Maya Ody-Ajike on 12/1/25.
//

import Foundation
import MusicKit

enum AppleMusicAuthError: Error {
    case notAuthorized
}

@MainActor
final class AppleMusicHelper {
    
    // Requests apple music acces via MusicKit and returns a simple AppleMusicInfo
    
    func appleMusicConnect() async throws -> AppleMusicInfo {
        // request musicki kit/apple music permission
        let status = await MusicAuthorization.request()
        
        guard status == .authorized else {
            throw AppleMusicAuthError.notAuthorized
        }
        
        // build app-level connection record
        let info = AppleMusicInfo(isConnected: true, lastUpdated: Date())
        
        return info
    }
}
