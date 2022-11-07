//
//  CharityFeed.swift
//  hewil
//
//  Created by vevebruh on 10/30/22.
//

import SwiftUI
import Alamofire

struct OrganisationCharityFeed: View {
    @StateObject private var data: OrganisationCharityFeedData = .init()
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack {
                    NavigationLink(destination: NewCharityPost(onEnd: {
                        data.shownNewPost = false
                        data.fetchPosts(isRefreshing: true)
                    }).navigationTitle("Новый пост"), isActive: $data.shownNewPost, label: { EmptyView() })
                    Section {
                        helpTypePicker
                            .padding(.bottom)
                    }
                    if let posts = data.feed {
                        ForEach(posts) { post in
                            NavigationLink(destination: CharityPostDetailView(post: post)) {
                                CharityPostCard(post: post)
                                    .padding(.bottom)
                            }.buttonStyle(.plain)

                        }
                        Text("")
                            .onAppear {
                                data.fetchPosts()
                            }
                    } else {
                        ProgressView()
                    }
                }.padding()
            }.refreshable {
                await withCheckedContinuation { continuation in
                    data.fetchPosts(isRefreshing: true) {
                        continuation.resume()
                    }
                }
            }
            .navigationTitle("Ваши запросы")
        .listStyle(.plain)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    data.shownNewPost = true
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.blue)
                }
            }
        }
        }
    }
    
    @ViewBuilder
    var helpTypePicker: some View {
        Picker(selection: $data.isPhysicalHelp, label: Text("")) {
            Text("Материальная")
                .tag(false)
            Text("Физическая")
                .tag(true)
        }.pickerStyle(.segmented)
    }
}

class OrganisationCharityFeedData: ObservableObject {
    @Published var shownNewPost: Bool = false
    @Published var city: String = "Москва"
    @Published private var posts: [CharityPost]? = nil
    @Published var isPhysicalHelp = false
    @Published var page = 1
    let limit = 20
    
    var feed: [CharityPost]? {
        guard let posts = self.posts else { return nil }
        return posts.filter { $0.isPhysical == isPhysicalHelp }
    }
    
    private let url = API.url.appendingPathComponent("charity").appendingPathComponent("orgposts")
    
    init() {
        fetchPosts()
    }
    
    func fetchPosts(isRefreshing: Bool = false, completion: @escaping () -> () = {}) {
        // Set authorization header
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(AppState.shared.organisationToken ?? "")"
        ]

        if isRefreshing { self.page = 1 }
        let parameters: [String: Any] = [
            "page": page,
            "limit": limit,
            "organisationScoped": true
        ]
        AF.request(url, method: .get, parameters: parameters, headers: headers).responseDecodable(of: OrganisationCharityFeedResponse.self) { response in
            print(String(data: response.data!, encoding: .utf8))
            switch response.result {
            case .success(let posts):
                withAnimation(.easeInOut) {
                    self.posts = posts.rows
                }
                self.page += 1
            case .failure(let error):
                print(error)
            }
            completion()
        }
    }
}

fileprivate struct OrganisationCharityFeedResponse: Decodable {
    let count: Int?
    let rows: [CharityPost]
}

struct OrganisationCharityFeed_Previews: PreviewProvider {
    static var previews: some View {
        OrganisationCharityFeed()
    }
}
