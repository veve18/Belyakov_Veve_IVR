//
//  OrganisationProfileView.swift
//  hewil
//
//  Created by vevebruh on 11/6/22.
//

import SwiftUI
import Alamofire

struct Organisation: Identifiable, Codable {
    var id: Int = 1
    var name: String
    var description: String?
    var email: String?
    var phone: String?
    var address: String?
    var city: String?
    var userpicURL: String?
    var contactLink: String?
}

struct OrganisationProfileView: View {
    var isEditable: Bool = false
    @State var organisation: Organisation
    @State var charityPosts: [CharityPost]? = nil
    @State var shelterPosts: [ShelterPost]? = nil
    @State var editSheetShown = false
    var body: some View {
        ScrollView {
                VStack {
                    AsyncImage(url: try? organisation.userpicURL?.asURL()) { img in
                        if let image = img.image {
                            image
                                .resizable()
                        } else {
                            Color.blue
                        }
                    }
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    Text(organisation.name)
                        .font(.title.bold())
                    Text(organisation.city ?? "Город не определен")
                    Text(organisation.description ?? "Нет описания")
                    Button(action: {
                        // Open telegram via URL
                        if !isEditable {
                            let tgURL = URL(string: organisation.contactLink ?? "https://google.com")!
                            UIApplication.shared.open(tgURL)
                        } else {
                            editSheetShown.toggle()
                        }
                    }) {
                        Text(isEditable ? "Изменить" : "Связаться")
                            .foregroundColor(.black)
                            .padding(.horizontal, 48)
                            .padding(.vertical, 8)
                            .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color("ButtonColor")))
                    }
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Все посты")
                                .font(.title2.bold())
                            Spacer()
                        }
                        if charityPosts != nil && shelterPosts != nil {
                            LazyVGrid(columns: [.init(.flexible()), .init(.flexible())]) {
                                ForEach(charityPosts ?? []) { post in
                                    CharityPostCard(post: post)
                                }
                                ForEach(shelterPosts ?? []) { post in
                                    ShelterPostCard(post: post)
                                }
                            }
                        } else {
                            ProgressView()
                        }
                    }.padding(.top, 18)
                }.ignoresSafeArea()
                .padding()
                .sheet(isPresented: $editSheetShown) { OrganisationEditView(organisation: organisation)
                }
            
        }.onAppear {
            fetchOrganisationData()
            fetchPosts()
        }
    }

    func fetchOrganisationData() {
        let url = API.url.appendingPathComponent("users").appendingPathComponent("org")
        let params = isEditable ? [:] : ["orgID": organisation.id]
        let headers = isEditable ? [
            "Authorization": "Bearer \(AppState.shared.organisationToken ?? "")"
        ] : [:]
        let headersHTTP = HTTPHeaders(headers)
        AF.request(url, method: .get, parameters: params, headers: headersHTTP).responseDecodable(of: [String: String].self) { response in
            switch response.result {
            case .success(let data):
                // Safely extract organisation data from response
                print(data)
                organisation.name = data["name"] ?? ""
                organisation.description = data["description"]
                organisation.email = data["email"]
                organisation.phone = data["phone"]
                organisation.address = data["address"]
                organisation.city = data["city"]
                organisation.userpicURL = data["userpicURL"]
                organisation.contactLink = data["contactLink"]
            case .failure(let error):
                print(error)
            }

        }
    }

    func fetchPosts() {
        let url = API.url.appendingPathComponent("users").appendingPathComponent("org").appendingPathComponent("posts")
        AF.request(url, method: .get, parameters: ["orgID": organisation.id]).responseJSON { response in
            switch response.result {
            case .success(let data):
                
                
                if let data = data as? [String: Any] {
                    if let charityPosts = data["charityPosts"] as? [[String: Any]] {
                        self.charityPosts = charityPosts.map {
                            return CharityPost(id: $0["id"] as! Int, title: $0["title"] as! String, description: $0["description"] as? String, charityOrganisationId: $0["charityOrganisationId"] as? Int, charityOrganisationTitle: $0["charityOrganisationTitle"] as? String, requisites: $0["requisites"] as? String, image: $0["image"] as! String, city: $0["city"] as? String, isPhysical: $0["isPhysical"] as? Bool)
                        }
                    }
                    if let shelterPosts = data["animalShelterPosts"] as? [[String: Any]] {
                        self.shelterPosts = shelterPosts.map { ShelterPost(id: $0["id"] as! Int, title: $0["title"] as! String, description: $0["description"] as? String, charityOrganisationId: $0["charityOrganisationId"] as? Int, charityOrganisationTitle: $0["charityOrganisationTitle"] as? String, contact: $0["contact"] as? String, image: $0["image"] as? String, city: $0["city"] as? String, animal: $0["animal"] as? String) }
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

struct OrganisationProfileView_Previews: PreviewProvider {
    static var previews: some View {
        OrganisationProfileView(isEditable: true, organisation: .init(name: "кошкин дом", userpicURL: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTGoCXLcx5AlJu3Kh1YgyKfu2FFvF-NOW7e2CWWrQsmbBVR2bKz6cWM0XiiO0W6L2Ihd20&usqp=CAU"))
    }
}
