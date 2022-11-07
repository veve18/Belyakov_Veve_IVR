//
//  ShelterPostDetailView.swift
//  hewil
//
//  Created by vevebruh on 10/31/22.
//

import SwiftUI

struct ShelterPostDetailView: View {
    var post: ShelterPost = .init(id: 1, title: "Тайтл скрин", contact: "+79259734423 Георгий")
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                AsyncImage(url: try? post.image?.asURL()) { img in
                    if let image = img.image {
                        image
                            .resizable()
                            .scaledToFill()
                    } else {
                        Color.blue
                    }
                }
                .frame(height: 200)
                .clipShape(Rectangle())
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading) {
                        NavigationLink(destination: OrganisationProfileView(organisation: .init(id: post.charityOrganisationId ?? 0, name: post.charityOrganisationTitle ?? "")).navigationBarTitle("Профиль", displayMode: .inline)) {
                            Text(post.charityOrganisationTitle ?? "название организации")
                                .font(.callout.smallCaps())
                                .foregroundColor(Color(uiColor: .systemGray4))
                        }
                        Text(post.title)
                            .font(.largeTitle.bold())
                    }
                    if let contacts = post.contact {
                        VStack(alignment: .leading) {
                            Text("Контакты")
                                .font(.title3.bold())
                            Text(contacts)
                                .textSelection(.enabled)
                        }
                    }
                    VStack(alignment: .leading) {
                        Text("Описание")
                            .font(.title3.bold())
                        Text(post.description ?? "")
                            .textSelection(.enabled)
                    }
                    
                }.padding(.horizontal)
            }
        }.ignoresSafeArea()
    }
}

struct ShelterPostDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ShelterPostDetailView()
    }
}
