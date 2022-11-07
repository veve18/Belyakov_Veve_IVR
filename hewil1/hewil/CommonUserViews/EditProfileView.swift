//
//  EditProfileView.swift
//  hewil
//
//  Created by vevebruh on 11/6/22.
//

import SwiftUI
import Alamofire

struct EditProfileView: View {
    var body: some View {
        NavigationView {
            
        }
    }
}

class EditProfileData: ObservableObject {
    init() {
        fetchInitialData()
    }
    
    @Published var name: String = ""
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var isLoaded: Bool = false

    // @ Route    /users/info
    // @ Method    GET
    // @ Description    Get user info
    // @ Access   Private
    // @ Returns   JSON with user info (firstName, lastName, username, email)

    let fetchInitialDataURL = API.url.appendingPathComponent("users").appendingPathComponent("info")

    func fetchInitialData() {
        self.isLoaded = false
        let headers = HTTPHeaders(["Authorization": "Bearer \(AppState.shared.userToken ?? "")"])
        AF.request(fetchInitialDataURL, method: .get, headers: headers).responseDecodable(of: [String: String].self) { response in
            switch response.result {
            case .success(let user):
                self.name = "\(user["firstName"] ?? "") \(user["lastName"] ?? "")"
                self.username = user["username"] ?? ""
                self.email = user["email"] ?? ""
                self.isLoaded = true
            case .failure(let error):
                print(error)
            }
        }
    }

    // @ Route    /users/edit
    // @ Method    POST
    // @ Description    Edit user info
    // @ Access   Private
    // @ Returns   JSON with user info (firstName, lastName, username, email)
    // @ Body     JSON with user info to edit (firstName, lastName, username, email)

    let editDataURL = API.url.appendingPathComponent("users").appendingPathComponent("edit")

    func editData() {
        self.isLoaded = false
        let headers = HTTPHeaders(["Authorization": "Bearer \(AppState.shared.userToken ?? "")"])
        let parameters: [String: String] = [
            "firstName": name.components(separatedBy: " ")[0],
            "lastName": name.components(separatedBy: " ")[1],
            "username": username,
            "email": email
        ]
        
        // Alamofire request with json body and response 
        AF.request(editDataURL, method: .post, parameters: parameters, headers: headers).responseDecodable(of: [String: String].self) { response in
            switch response.result {
            case .success(let data):
                print(data)
                // Save token to AppState
                AppState.shared.userToken = data["token"]
                self.isLoaded = true
            case .failure(let error):
                print(error)
            }
        }

    }

}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView()
    }
}
