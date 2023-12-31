//
//  Resources.swift
//  MyMusicApp
//
//  Created by Andrey on 11.06.2023.
//

import Foundation
import UIKit

enum Keys {
    static let favorites = "favorites"
}

enum Web {
    static let clientID = "bf130a2999604796a93c9fca3f16cc1f"
    static let secretID = "38ad284a59114f8997ec8e254e68641e"
    static let tokenApiURL = "https://accounts.spotify.com/api/token"
    static let redirectURI = "https://google.com"
    static let scopes = "user-read-private%20user-read-playback-state%20app-remote-control%20streaming%20playlist-read-private%20user-read-recently-played%20user-read-email"
    
    static let baseURL = "https://api.spotify.com/v1"
}

enum Resources {
    enum Colors {
        enum TabBarColors{
            static var active = UIColor(hex: 0xCBFB5E)
            static var inactive = UIColor(hex: 0x71737B)
            static var background = UIColor(hex: 0x0E0B1F)
            static var backgraundCell = UIColor(hex: 0x1D1839)
        }
        
        static var resetPasswordBG = UIColor(hex: 0x0E0B1F)
        
        static var brand1 = UIColor(hex: 0xCBFB5E)
        static var brand2 = UIColor(hex: 0x0E0B1F)
        static var neutral1 = UIColor(hex: 0xEEEEEE)
        static var neutral2 = UIColor(hex: 0x7A7C81)
        static var neutral3 = UIColor(hex: 0x20242F)
        static var bacgroundSettings = UIColor(hex: 0x363942)
    }
    
    enum Icons {
        enum TabBar {
            static var home = UIImage(named: "home.svg")
            static var explore = UIImage(named: "pin.svg")
            static var favorites = UIImage(named: "favorite.svg")
            static var account = UIImage(named: "user.svg")
        }
        
        enum SignInUp {
            static var userName = UIImage(named: "userName.svg")
            static var email = UIImage(named: "email.svg")
            static var password = UIImage(named: "password.svg")
            static var showPassword = UIImage(named: "eye-17.svg")
            static var googleIcon = UIImage(named: "google-plus.svg")
        }
        
        enum Common {
            static var back = UIImage(systemName: "arrowshape.backward.fill")
            static var search = UIImage(systemName: "magnifyingglass")
        }
    }
    
    enum Images {
        enum Backgrounds {
            static var signIn = UIImage(named: "signInBackground")
            static var signUp = UIImage(named: "signUpBackground")
        }
    }
    
    enum Strings {
        enum TabBar {
            static var home = "Home"
            static var explore = "Explore"
            static var favorites = "Favorites"
            static var account = "Account"
        }
    }
    
    enum Fonts {
        static func RobotoRegular(with size: CGFloat) -> UIFont {
            UIFont(name: "Roboto", size: size) ?? UIFont()
        }
        static func RobotoBold(with size: CGFloat) -> UIFont {
            UIFont(name: "Roboto-Bold", size: size) ?? UIFont()
        }
    }
}
