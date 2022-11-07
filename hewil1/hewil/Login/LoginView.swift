//
//  LoginView.swift
//  hewil
//
//  Created by vevebruh on 10/30/22.
//

import SwiftUI
import Alamofire

struct LoginView: View {
    @StateObject var data: LoginData = LoginData()
    @Binding var authState: UnauthorizedStates?
    @ObservedObject var appState = AppState.shared
    var body: some View {
        VStack(alignment: .leading) {
            Form {
                Text("Войти в hewil")
                    .font(.largeTitle)
                    .bold()
                if data.error != nil {
                    Text(data.error ?? "smthng went wrong")
                }
                Section {
                    TextField("E-mail или юзернейм", text: $data.email)
                }
                Section {
                    SecureField("Пароль", text: $data.password)
                }
                Section {
                    Button(action: {
                        data.login() { result in
                            appState.userToken = try? result.get()
                        }
                    }) {
                        Text("Войти")
                            .foregroundColor(.blue)
                    }
                }
                Section {
                    Button(action: {
                        self.authState = .registration
                    }) {
                        Text("Еще нет аккаунта? Зарегистрируйтесь")
                            .foregroundColor(.blue)
                    }
                    Button(action: {
                        authState = .orgLogin
                    }) {
                        Text("Войти как НКО")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
}

class OrgLoginData: ObservableObject {
    @Published var error: String? = nil
    @Published var email: String = ""
    @Published var password: String = ""
    private let url = API.url.appendingPathComponent("charity").appendingPathComponent("login")
    
    // Login function with completion handler (result<string, error>)
    func login(completion: @escaping (Result<String, Error>) -> Void) {
        let parameters: [String: String] = [
            "email": email,
            "password": password
        ]
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let json = value as? [String: Any] {
                    if let token = json["token"] as? String {
                        completion(.success(token))
                    } else {
                        completion(.failure(NSError(domain: "hewil", code: 0, userInfo: [NSLocalizedDescriptionKey: "No token"])))
                    }
                } else {
                    completion(.failure(NSError(domain: "hewil", code: 0, userInfo: [NSLocalizedDescriptionKey: "No json"])))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

struct OrganisationLoginView_Previews: PreviewProvider {
    static var previews: some View {
        OrganisationLoginView(authState: .constant(.login))
    }
}
