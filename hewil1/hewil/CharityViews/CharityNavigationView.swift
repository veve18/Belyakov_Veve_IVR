//
//  CharityNavigationView.swift
//  hewil
//
//  Created by vevebruh on 11/2/22.
//

import SwiftUI

struct CharityNavigationView: View {
    var body: some View {
        TabView {
            OrganisationCharityFeed()
                .tabItem {
                    Label("Помощь", systemImage: "sparkles")
                }
            OrganisationSheltersFeed()
                .tabItem {
                    Label("Приюты", systemImage: "house.fill")
                }
            OrganisationProfileView(isEditable: true, organisation: .init(name: ""))
                .tabItem {
                    Label("Профиль", systemImage: "person.circle")
                }
        }.accentColor(.blue)
    }
}

struct CharityNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        CharityNavigationView()
    }
}
