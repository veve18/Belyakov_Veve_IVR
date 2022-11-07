//
//  LikedPosts.swift
//  hewil
//
//  Created by vevebruh on 11/7/22.
//

import SwiftUI
import Alamofire

struct LikedPosts: View {
    @State var posts: [ShelterPost]? = nil
    var body: some View {
        NavigationView {
            ScrollView {
                if let posts = self.posts {
                    LazyVGrid(columns: [.init(.flexible()), .init(.flexible())]) {
                        ForEach(posts) { post in
                            NavigationLink(destination: ShelterPostDetailView(post: post)) {
                                ShelterPostCard(post: post)
                                    .padding(.bottom)
                            }.buttonStyle(.plain)
                                .scaleEffect(0.8)
                        }
                    }.padding(.horizontal)
                } else {
                    ProgressView()
                }
            }.navigationTitle("Ваши лайки")
        }.onAppear {
            let url = API.url.appendingPathComponent("charity").appendingPathComponent("posts")
            // Get liked posts ID from UserDefaults
            let likedPosts = UserDefaults.standard.array(forKey: "likedPosts") as? [Int]
            // Get posts from API via POST request
            AF.request(url, method: .post, parameters: ["post_ids": likedPosts], encoder: JSONParameterEncoder.default).responseDecodable(of: [ShelterPost].self) { response in
                if let posts = response.value {
                    self.posts = posts
                }
            }
        }
    }
}

struct LikedPosts_Previews: PreviewProvider {
    static var previews: some View {
        LikedPosts()
    }
}
