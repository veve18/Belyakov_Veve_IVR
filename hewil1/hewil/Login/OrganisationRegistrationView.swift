//
//  RegistrationView.swift
//  hewil
//
//  Created by vevebruh on 10/30/22.
//

import SwiftUI
import Alamofire

struct OrganisationRegistrationView: View {
    @StateObject private var data = OrganisationRegistrationData()
    @ObservedObject private var appState = AppState.shared
    @Binding var authState: UnauthorizedStates?
    var body: some View {
        VStack(alignment: .leading) {
            Form {
                Text("Регистрация\nв hewil как НКО")
                    .font(.largeTitle)
                    .bold()
                if data.error != nil {
                    Text(data.error ?? "smthng went wrong")
                }
                Section {
                    TextField("Название организации", text: $data.name)
                        .textContentType(.name)
                }
                Section {
                    TextField("E-mail", text: $data.email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                }
                Section {
                    TextField("Телефон", text: $data.phone)
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)
                }
                Section {
                    TextField("Город", text: $data.city)
                        .textContentType(.username)
                }
                Section {
                    TextField("Контакт для связи (публичный)", text: $data.contactLink)
                }
                Section {
                    SecureField("Пароль", text: $data.password)
                        .textContentType(.newPassword)
                }
                Section {
                    Button(action: {
                        data.register() { result in
                            appState.organisationToken = try? result.get()
                        }
                    }, label: {
                        Text("Зарегистрироваться")
                            .foregroundColor(.blue)
                    })
                }
                Section {
                    Button(action: {
                        authState = .orgLogin
                    }, label: {
                        Text("Уже есть аккаунт")
                            .foregroundColor(.blue)
                    })
                    Button(action: {
                        authState = .registration
                    }) {
                        Text("Вы — частное лицо?")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
}

class OrganisationRegistrationData: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var phone: String = "+7"
    @Published var city: String = ""
    @Published var password: String = ""
    @Published var contactLink: String = ""
    @Published var error: String? = nil
    
    var token: String? = nil

    func validateValues() -> Bool {
        name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        city = city.trimmingCharacters(in: .whitespacesAndNewlines)
        password = password.trimmingCharacters(in: .whitespacesAndNewlines)

        if name.isEmpty || email.isEmpty || city.isEmpty || password.isEmpty {
            error = "Заполните все поля"
            return false
        }

        if password.count < 6 {
            error = "Пароль должен быть не менее 6 символов"
            return false
        }

        return true
        
    }
    
    func register(completion: @escaping (Result<String, Error>) -> Void) {
        let parameters: [String: String] = [
            "name": name,
            "email": email,
            "password": password,
            "city": city,
            "phone": phone,
            "contactLink": contactLink
        ]
        
        AF.request(API.url.appendingPathComponent("charity"), method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            switch response.result {
            case .success(let value):
                // Get token from response dictionary ({ token: "..." })
                print(value)
                guard let token = (value as? [String: String] ?? [:])["token"] else { return completion(.failure(AFError.responseValidationFailed(reason: .dataFileNil))) }
                self.token = token
                completion(.success(token))
            case .failure(let error):
                self.error = error.errorDescription
                completion(.failure(error))
            }
        }
    }
}

struct OrganisationRegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        OrganisationRegistrationView(authState: .constant(.orgReg))
    }
}
