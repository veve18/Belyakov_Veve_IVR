//
//  OrganisationSheltersFeed.swift
//  hewil
//
//  Created by vevebruh on 10/31/22.
//

import SwiftUI
import Alamofire

struct OrganisationSheltersFeed: View {
    @StateObject private var data = OrganisationShelterFeedData()
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack {
                    NavigationLink(destination: NewShelterPost(onEnd: {
                        data.shownNewPost = false
                        data.fetchPosts(isRefreshing: true)
                    }).navigationTitle("Новый пост"), isActive: $data.shownNewPost, label: { EmptyView() })
                    if data.posts == nil {
                        ProgressView()
                    } else {
                        LazyVGrid(columns: data.gridView ? [GridItem(.flexible()), GridItem(.flexible())] : [GridItem(.flexible())]) {
                            ForEach(data.posts!) { post in
                                NavigationLink(destination: ShelterPostDetailView(post: post)) {
                                    ShelterPostCard(post: post)
                                        .padding(.bottom)
                                }.buttonStyle(.plain)
                            }
                        }
                    }
                }.padding()
            }
            .navigationTitle("Ваши объявления")
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button(action: {
                            withAnimation {
                                data.gridView.toggle()
                            }
                        }) {
                            Image(systemName: data.gridView ? "square.fill" : "square.grid.2x2.fill")
                                .foregroundColor(.blue)
                        }
                        
                        Button(action: {
                            data.shownNewPost = true
                        }) {
                            Image(systemName: "plus")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .refreshable {
                    await withCheckedContinuation { continuation in
                        data.fetchPosts(isRefreshing: true) {
                            continuation.resume()
                        }
                    }
            }
        }
    }
}

class OrganisationShelterFeedData: ObservableObject {
    @Published var gridView = false
    @Published var posts: [ShelterPost]? = nil
    var feed: [ShelterPost]? {
        return posts
    }
    @Published var page = 1
    let limit = 20
    @Published var city = "Москва"
    @Published var shownNewPost: Bool = false
    let url = API.url.appendingPathComponent("charity").appendingPathComponent("shelter").appendingPathComponent("orgposts")

    init() {
        self.fetchPosts()
    }
    
    func fetchPosts(isRefreshing: Bool = false, completion: (() -> Void)? = nil) {
        let headers = HTTPHeaders(["Authorization": "Bearer \(AppState.shared.organisationToken ?? "")"])
        if isRefreshing {
            page = 1
        }
        let parameters: [String: String] = [
            "city": city,
            "page": String(page),
            "limit": String(limit),
            "organisationScoped": "true"
        ]
        AF.request(url, method: .get, parameters: parameters, headers: headers).responseDecodable(of: OrganisationShelterResponse.self) { response in
            switch response.result {
            case .success(let posts):
                withAnimation(.easeInOut) {
                    self.posts = posts.rows
                }
                self.page += 1
            case .failure(let error):
                print(error)
            }
            completion?()
        }
    }
}

fileprivate struct OrganisationShelterResponse: Decodable {
    let rows: [ShelterPost]
    let count: Int
}

struct OrganisationSheltersFeed_Previews: PreviewProvider {
    static var previews: some View {
        OrganisationSheltersFeed()
    }
}
