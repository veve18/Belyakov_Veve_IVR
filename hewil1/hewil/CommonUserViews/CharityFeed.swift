//
//  CharityFeed.swift
//  hewil
//
//  Created by vevebruh on 10/30/22.
//

import SwiftUI
import Alamofire

struct CharityFeed: View {
    @StateObject private var data: CharityFeedData = .init()
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack {
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
            .navigationTitle("Помощь")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { data.filtersShown.toggle() }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundColor(.blue)
                    }
                }
            }
        .listStyle(.plain)
        }.accentColor(Color("ButtonColor"))
            .sheet(isPresented: $data.filtersShown) {
                CharityFilters(onSave: data.onFilterSave(filters:))
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

class CharityFeedData: ObservableObject {
    @Published var city: String = "Москва"
    @Published private var posts: [CharityPost]? = nil
    @Published var isPhysicalHelp = false
    @Published var page = 1
    @Published var filtersShown = false
    let limit = 20
    
    func onFilterSave(filters: [String: String]) {
        self.filtersShown = false
        self.city = filters[CharityFilter.city.rawValue] ?? "Москва"
        posts = nil
        self.fetchPosts(isRefreshing: true)
    }
    
    var feed: [CharityPost]? {
        guard let posts = self.posts else { return nil }
        return posts.filter { $0.isPhysical == isPhysicalHelp }
    }
    
    private let url = API.url.appendingPathComponent("charity").appendingPathComponent("posts")
    
    init() {
        fetchPosts()
    }
    
    func fetchPosts(isRefreshing: Bool = false, completion: @escaping () -> () = {}) {
        if isRefreshing { self.page = 1 }
        let parameters: [String: Any] = [
            "city": city,
            "page": page,
            "limit": limit
        ]
        AF.request(url, method: .get, parameters: parameters).responseDecodable(of: CharityPostsResponse.self) { response in
            print(String(data: response.data ?? .init(), encoding: .utf8))
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

fileprivate struct CharityPostsResponse: Decodable {
    let count: Int
    let rows: [CharityPost]
}

struct CharityFeed_Previews: PreviewProvider {
    static var previews: some View {
        CharityFeed()
    }
}
