//
//  UserNavigationView.swift
//  hewil
//
//  Created by vevebruh on 11/1/22.
//

import SwiftUI

struct UserNavigationView: View {
    @State var tab = "charity"
    var body: some View {
        TabView {
            SheltersFeed()
                .navigationTitle("hewil")
                .tabItem {
                    Label("Приюты", systemImage: "house.fill")
                }
                
            LikedPosts()
                .tabItem {
                    Label("Лайки", systemImage: "star.fill")
                }
            
            CharityFeed()
                .navigationTitle("Помощь")
                .tabItem {
                    Label("Помощь", systemImage: "sparkles")
                }
            
        }.accentColor(Color("ButtonColor"))
//        .navigationTitle("hewil")

    }
}

struct UserNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UserNavigationView()
                .navigationBarHidden(false)
        }
    }
}
