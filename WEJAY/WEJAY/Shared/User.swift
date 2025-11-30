//
//  User.swift
//  WEJAY
//
//  Created by Maya Ody-Ajike on 11/25/25.
//

import Foundation

struct UserrArray: Codable {
    let users: [Userr]
    let total, skip, limit: Int
}

struct Userr: Codable, Identifiable {
    let id: Int
    let firstName, lastName: String
    let age: Int
    let email, phone, username, password: String
    let image: String
    let height: Double // <- Double not Int
    let weight: Double
    
    var work: String {
        "Worker as Some Job"
    }
    var education: String {
        "Graduate Degree"
    }
    var aboutMe: String {
        "This is a sentence about me that will look good on my profile!"
    }
//    var basics: [UserrInterest] {
//        [
//            UserInterest(iconName: "ruler", emoji: nil, text: "\(height)"),
//            UserInterest(iconName: "graduationcap", emoji: nil, text: education),
//            UserInterest(iconName: "wineglass", emoji: nil, text: "Socially"),
//            UserInterest(iconName: "moon.stars.fill", emoji: nil, text: "Virgo"),
//        ]
//    }
//    var interests: [UserrInterest] {
//        [
//            UserInterest(iconName: nil, emoji: "👟", text: "Running"),
//            UserInterest(iconName: nil, emoji: "🏋️‍♂️", text: "Gym"),
//            UserInterest(iconName: nil, emoji: "🎧", text: "Music"),
//            UserInterest(iconName: nil, emoji: "🥘", text: "Cooking"),
//        ]
//    }
    var images: [String] {
        ["https://picsum.photos/500/500", "https://picsum.photos/600/600", "https://picsum.photos/700/700"]
    }
    
    static var mock: Userr {
        Userr(
            id: 444,
            firstName: "Maya",
            lastName: "Lanski",
            age: 21,
            email: "hi@hi.com",
            phone: "",
            username: "",
            password: "",
            image: Constants.randomImage,
            height: 180,
            weight: 200
        )
    }
}
