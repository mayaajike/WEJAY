//
//  APIConstants.swift
//  WEJAY
//
//  Created by Maya Ody-Ajike on 12/1/25.
//

import Foundation

enum SpotifyAPIConstants {
    static let apiHost = "api.spotify.com"
    static let authHost = "accounts.spotify.com"
    static let clientId = "e1487454cb9148dbae59eab08533a2b4"
    static let redirectUri = "wejay://callback"
    static let scope = """
    user-read-private user-read-email playlist-read-private playlist-modify-private playlist-modify-public playlist-read-collaborative user-top-read
    """
}
