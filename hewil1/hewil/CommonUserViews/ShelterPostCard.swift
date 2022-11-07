//
//  ShelterPostCard.swift
//  hewil
//
//  Created by vevebruh on 10/31/22.
//

import SwiftUI

struct ShelterPostCard: View {
    var post: ShelterPost
    @State var isLiked: Bool = false
    @ObservedObject private var appState = AppState.shared

    init(post: ShelterPost) {
        self.post = post
        self._isLiked = .init(initialValue: appState.likedPosts.contains(post.id))
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AsyncImage(url: try? post.image?.asURL()) { img in
                if let image = img.image {
                    image
                        .resizable()
                        .scaledToFill()
                } else {
                    Color.blue
                }
            }
            .frame(height: 150)
            .clipShape(Rectangle())
            VStack(alignment: .leading) {
                Text("\(post.charityOrganisationTitle ?? "организация") / \(post.animal ?? "Животное")")
                    .font(.caption.smallCaps())
                    .foregroundColor(.init(uiColor: .systemGray4))
                
                Text(post.title)
                    .font(.title2.bold())
            }
            .padding()
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color(uiColor: .systemGray5), lineWidth: 1)
        }
        .overlay(alignment: .topTrailing) {
            if appState.isUserLoggedIn() {
                Button(action: {
                    if isLiked {
                        appState.likedPosts.removeAll(where: { $0 == post.id })
                    } else {
                        appState.likedPosts.append(post.id)
                    }
                    isLiked.toggle()
                }) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .foregroundColor(isLiked ? .red : .gray)
                        .padding(8)
                        .background(Color.white)
                        .clipShape(Circle())
            }.padding()
            } else {
                EmptyView()
            }
        }
    }
}

struct ShelterPostCard_Previews: PreviewProvider {
    static var previews: some View {
        ShelterPostCard(post: .init(id: 1))
    }
}
