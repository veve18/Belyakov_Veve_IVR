//
//  hewilApp.swift
//  hewil
//
//  Created by vevebruh on 10/30/22.
//

import SwiftUI

@main
struct hewilApp: App {
    @ObservedObject private var appState = AppState.shared
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ZStack {
                    NavigationLink(isActive: .constant(appState.organisationToken != nil), destination: { CharityNavigationView().navigationBarBackButtonHidden(true) }, label: { EmptyView() })
                        .navigationBarBackButtonHidden(true)
                    NavigationLink(isActive: .constant(appState.userToken != nil), destination: { UserNavigationView().navigationBarBackButtonHidden(true) }, label: { EmptyView() })
//                        .navigationBarBackButtonHidden(true)
                    if !appState.isUserOrOrganisationLoggedIn() {
                        UnauthorizedView()
                    }
//                    OrganisationRegistrationView()
//                    CharityFeed()
//                    SheltersFeed()
//                    UserNavigationView()
//                    CharityNavigationView()
                }
            }.navigationBarHidden(true)

        }
    }
}
