//
//  AppState.swift
//  hewil
//
//  Created by vevebruh on 10/30/22.
//

import Foundation

class AppState: ObservableObject {
    public static let shared = AppState()
    
    @Published var organisationToken: String? = nil {
        didSet {
            UserDefaults.standard.set(organisationToken, forKey: "organisationToken")
        }
    }
    @Published var userToken: String? = nil {
        didSet {
            UserDefaults.standard.set(userToken, forKey: "userToken")
        }
    }
    
    @Published var likedPosts: [Int] = [] {
        didSet {
            UserDefaults.standard.set(likedPosts, forKey: "likedPosts")
        }
    }

    init() {
        organisationToken = UserDefaults.standard.string(forKey: "organisationToken")
        userToken = UserDefaults.standard.string(forKey: "userToken")
        likedPosts = UserDefaults.standard.array(forKey: "likedPosts") as? [Int] ?? []
        print(likedPosts)
    }

    func logout() {
        organisationToken = nil
        userToken = nil
    }

    func isUserLoggedIn() -> Bool {
        return userToken != nil
    }

    func isOrganisationLoggedIn() -> Bool {
        return organisationToken != nil
    }

    func isUserOrOrganisationLoggedIn() -> Bool {
        return isUserLoggedIn() || isOrganisationLoggedIn()
    }

    
}
