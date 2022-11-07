//
//  OrganisationEditView.swift
//  hewil
//
//  Created by vevebruh on 11/7/22.
//

import SwiftUI
import Alamofire

struct OrganisationEditView: View {
    @State var organisation: Organisation
    @State var imagePickerPresented: Bool = false
    @State var image: UIImage? = nil
    @State var successAlertPresented: Bool = false
    @State var isLoading: Bool = true
    @State var errorAlertPresented: Bool = false
    @State var errorLoadingAlertPresented: Bool = false
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Основная информация")) {
                    TextField("Название", text: $organisation.name)
                    TextField("Описание", text: $organisation.description ?? "")
                    TextField("Email", text: $organisation.email ?? "")
                    TextField("Телефон", text: $organisation.phone ?? "")
                    TextField("Адрес", text: $organisation.address ?? "")
                    TextField("Город", text: $organisation.city ?? "")
                    TextField("Контакт для связи, виден всем", text: $organisation.contactLink ?? "")
                }.alert(
                    isPresented: $errorAlertPresented,
                    content: {
                        Alert(
                            title: Text("Ошибка"),
                            message: Text("Не удалось сохранить изменения"),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                )
                Section(header: Text("Фото")) {
                    if self.image == nil {
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
                        .onTapGesture {
                            self.imagePickerPresented.toggle()
                        }
                        .sheet(isPresented: $imagePickerPresented) {
                            ImagePickerSheet(image: $image)
                    }
                    } else {
                        Image(uiImage: image ?? .add)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .onTapGesture {
                                self.imagePickerPresented.toggle()
                            }
                            .sheet(isPresented: $imagePickerPresented) {
                                ImagePickerSheet(image: $image)
                        }
                    }
                }.alert(
                    isPresented: $errorLoadingAlertPresented,
                    content: {
                        Alert(
                            title: Text("Ошибка"),
                            message: Text("Не удалось получить данные"),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                )
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        saveOrganisation()
                    }) {
                        Text("Сохранить")
                    }.foregroundColor(.blue)
                }
            }
            .alert(
                isPresented: $successAlertPresented,
                content: {
                    Alert(
                        title: Text("Успешно"),
                        message: Text("Организация успешно сохранена"),
                        dismissButton: .default(Text("Ок"))
                    )
                }
            )
            .onAppear {
                self.getOrganisationDetails()
            }
            
        }
    }

    func getOrganisationDetails() {
        let url = API.url.appendingPathComponent("charity").appendingPathComponent("account")
        let headers = HTTPHeaders(["Authorization": "Bearer \(AppState.shared.organisationToken ?? "")"])

        AF.request(url, headers: headers).responseDecodable(of: Organisation.self) { response in
            switch response.result {
            case .success(let organisation):
                self.organisation = organisation
                isLoading = false
            case .failure(let error):
                print(error)
                isLoading = false
                errorLoadingAlertPresented = true
            }
        }

    }

    func saveOrganisation() {
        let url = API.url.appendingPathComponent("charity").appendingPathComponent("account")
        // PUT request with Alamofire to save organisation
        // Don't include image

        let headers = HTTPHeaders([
            "Authorization": "Bearer \(AppState.shared.organisationToken ?? "")"
        ])

        let parameters = [
            "name": organisation.name,
            "description": organisation.description ?? "",
            "email": organisation.email ?? "",
            "phone": organisation.phone ?? "",
            "address": organisation.address ?? "",
            "city": organisation.city ?? "",
            "contactLink": organisation.contactLink ?? ""
        ]

        if image != nil {
            let userpicUploadURL = API.url.appendingPathComponent("charity").appendingPathComponent("account").appendingPathComponent("userpic")
            let userpicUploadHeaders = HTTPHeaders([
                "Authorization": "Bearer \(AppState.shared.organisationToken ?? "")"
            ])
            AF.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(self.image!.jpegData(compressionQuality: 0.5)!, withName: "file", fileName: "userpic.jpg", mimeType: "image/jpeg")
            }, to: userpicUploadURL, method: .post, headers: userpicUploadHeaders).responseDecodable(of: Organisation.self) { response in
                switch response.result {
                case .success(let organisation):
                    break
                case .failure(let error):
                    print(error)
                    self.errorAlertPresented = true
                }
            }
        }

        AF.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
            // Guard status codes are 200-299
                guard let statusCode = response.response?.statusCode, 200...299 ~= statusCode else {
                    self.errorAlertPresented.toggle()
                    return
                }
                successAlertPresented = true
            case .failure(let error):
                print(error)
                errorAlertPresented = true
            }
        }
    }
}

struct OrganisationEditView_Previews: PreviewProvider {
    static var previews: some View {
        OrganisationEditView(organisation: .init(name: "b"))
    }
}

func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}
