//
//  SheltersFeed.swift
//  hewil
//
//  Created by vevebruh on 10/31/22.
//

import SwiftUI
import Alamofire

struct SheltersFeed: View {
    @StateObject private var data = ShelterFeedData()
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack {
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
            .navigationTitle("hewil")
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
                            Button(action: { data.filtersShown.toggle() }) {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                    .foregroundColor(.blue)
                            }            .sheet(isPresented: $data.filtersShown) {
                                ShelterFilters(onSave: data.onFilterSave(filters:))
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
        }.accentColor(Color("ButtonColor"))
    }
}

class ShelterFeedData: ObservableObject {
    @Published var gridView = false
    @Published var posts: [ShelterPost]? = nil
    @Published var filtersShown = false
    var feed: [ShelterPost]? {
        return posts
    }
    @Published var page = 1
    let limit = 20
    @Published var city = "Москва"
    @Published var animal: String? = nil
    let url = API.url.appendingPathComponent("charity").appendingPathComponent("shelter").appendingPathComponent("posts")

    func onFilterSave(filters: [String: String]) {
        self.filtersShown = false
        self.city = filters[ShelterFilter.city.rawValue] ?? "Москва"
        self.animal = filters[ShelterFilter.animal.rawValue]
        posts = nil
        self.fetchPosts(isRefreshing: true)
    }
    
    init() {
        self.fetchPosts()
    }
    
    func fetchPosts(isRefreshing: Bool = false, completion: (() -> Void)? = nil) {
        if isRefreshing {
            page = 1
        }
        var parameters: [String: String] = [
            "city": city,
            "page": String(page),
            "limit": String(limit)
        ]
        if animal != nil {
            parameters[ShelterFilter.animal.rawValue] = animal
        }
        AF.request(url, method: .get, parameters: parameters).responseDecodable(of: ShelterResponse.self) { response in
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

fileprivate struct ShelterResponse: Decodable {
    let rows: [ShelterPost]
    let count: Int
}

struct SheltersFeed_Previews: PreviewProvider {
    static var previews: some View {
        SheltersFeed()
    }
}
