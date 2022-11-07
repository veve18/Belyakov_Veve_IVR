//
//  CharityPostDetailView.swift
//  hewil
//
//  Created by vevebruh on 10/31/22.
//

import SwiftUI

struct CharityPostDetailView: View {
    var post: CharityPost = .init(id: 1, title: "кек тайтл", requisites: "4400 9000 1239 2392")
    var body: some View {
        ScrollView {
            VStack(alignment: .leading){
                AsyncImage(url: try? post.image.asURL()) { img in
                    if let image = img.image {
                        image
                            .resizable()
                    } else {
                        Rectangle()
                            .fill(.blue)
                    }
                }
                .frame(height: 220)
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading) {
                        NavigationLink(destination: OrganisationProfileView(organisation: .init(id: post.charityOrganisationId ?? 0, name: post.charityOrganisationTitle ?? "")).navigationBarTitle("Профиль", displayMode: .inline)) {
                            Text(post.charityOrganisationTitle ?? "название организации")
                                .font(.callout.smallCaps())
                                .foregroundColor(Color(uiColor: .systemGray4))
                        }
                        Text(post.title)
                            .font(.largeTitle)
                            .bold()
                    }
                    if let requisites = post.requisites {
                        VStack(alignment: .leading) {
                            Text("Реквизиты")
                                .font(.title3.bold())
                            Text(requisites)
                                .textSelection(.enabled)
                        }
                    }
                    VStack (alignment: .leading) {
                        Text("Описание")
                            .font(.title3.bold())
                        Text(post.description ?? "")
                            .textSelection(.enabled)
                    }
                }.padding()
            }
        }.ignoresSafeArea()
    }
}

struct CharityPostDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CharityPostDetailView()
    }
}
