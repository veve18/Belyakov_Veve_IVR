//
//  RegistrationView.swift
//  hewil
//
//  Created by vevebruh on 10/30/22.
//

import SwiftUI
import Alamofire

struct RegistrationView: View {
    @StateObject private var data = RegistrationData()
    @ObservedObject var appState = AppState.shared
    @Binding var authState: UnauthorizedStates?
    var body: some View {
        VStack(alignment: .leading) {
            Form {
                Text("Добро пожаловать\nв hewil!")
                    .font(.largeTitle)
                    .bold()
                if data.error != nil {
                    Text(data.error ?? "smthng went wrong")
                }
                Section {
                    TextField("Имя", text: $data.name)
                        .textContentType(.name)
                }
                Section {
                    TextField("E-mail", text: $data.email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                }
                Section {
                    TextField("Юзернейм", text: $data.username)
                        .textContentType(.username)
                }
                Section {
                    SecureField("Пароль", text: $data.password)
                        .textContentType(.newPassword)
                }
                Section {
                    Button(action: {
                        data.register() { result in
                            appState.userToken = try? result.get()
                        }
                    }, label: {
                        Text("Зарегистрироваться")
                            .foregroundColor(.blue)
                    })
                }
                Section {
                    Button(action: {
                        authState = .login
                    }, label: {
                        Text("Уже есть аккаунт")
                            .foregroundColor(.blue)
                    })
                    Button(action: {
                        authState = .orgReg
                    }) {
                        Text("Регистрация как НКО")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
}

struct API {
    public static let url = URL(string: "http://localhost:3000/")!
}

class RegistrationData: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""

    // TODO: username sanitization
    @Published var username: String = "" {
        didSet {
            if username.contains(" ") {
                username = oldValue
            }
        }
    }

    @Published var password: String = ""
    @Published var error: String? = nil
    
    var token: String? = nil

    func validateValues() -> Bool {
        name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        username = username.trimmingCharacters(in: .whitespacesAndNewlines)
        password = password.trimmingCharacters(in: .whitespacesAndNewlines)

        if name.isEmpty || email.isEmpty || username.isEmpty || password.isEmpty {
            error = "Заполните все поля"
            return false
        }

        if password.count < 5 {
            error = "Пароль должен быть не менее 5 символов"
            return false
        }

        return true
        
    }
    
    func register(completion: @escaping (Result<String, Error>) -> Void) {
        let parameters: [String: String] = [
            "firstName": name,
            "lastName": "sample",
            "email": email,
            "password": password,
            "username": username
        ]
        
        AF.request(API.url.appendingPathComponent("users").appendingPathComponent("register"), method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            switch response.result {
            case .success(let value):
                // Get token from response dictionary ({ token: "..." })
                print(value)
                guard let token = (value as! [String: String])["token"] else { return completion(.failure(AFError.responseValidationFailed(reason: .dataFileNil))) }
                self.token = token
                completion(.success(token))
            case .failure(let error):
                self.error = error.errorDescription
                completion(.failure(error))
            }
        }
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView(authState: .constant(.registration))
    }
}
