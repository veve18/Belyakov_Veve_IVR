//
//  NewShelterPost.swift
//  hewil
//
//  Created by vevebruh on 11/2/22.
//

import SwiftUI
import Combine
import Alamofire

struct NewShelterPost: View {
    @StateObject private var data = NewShelterPostData()
    var onEnd: () -> () = {}
    var body: some View {
        Form {
            Section {
                TextField("Название", text: $data.title)
                TextEditor(text: $data.description)
                    .background(alignment: .leading) {
                        if data.description.isEmpty {
                            Text("Описание")
                                .foregroundColor(.secondary)
                        }
                    }
            }
            Section {
                TextField("Город", text: $data.city)
            }
            Section {
                TextField("Контакты", text: $data.requisites)
                    .textContentType(.telephoneNumber)
            }
            Section {
                Picker("Животное", selection: $data.animal) {
                    Text("Кошка")
                        .tag("Кошка")
                    Text("Собака")
                        .tag("Собака")
                }
            }
            Section {
                // Button to choose image
                Button(action: {
                    data.pickImage()
                }) {
                    HStack {
                        if let image = data.image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 24, height: 18)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        } else {
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 24, height: 18)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                        Text("\(data.image == nil ? "Добавить" : "Изменить") фото")
                    }.foregroundColor(.blue)
                }
            }
            Section(footer: VStack {
                if let error = data.error {
                    Text(error)
                        .foregroundColor(.red)
                }
            }) {
                Button(action: {
                    data.isLoading = true
                    data.post(completion: {
                        onEnd()
                        data.isLoading = false
                    }, failure: {
                        data.isLoading = false
                    })
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Создать пост")
                    }.foregroundColor(.blue)
                }
                
            }
        }.sheet(isPresented: $data.isImagePickerPresented, onDismiss: {}) {
            ImagePickerSheet(image: $data.image)
        }
    }
}

@MainActor
class NewShelterPostData: ObservableObject {
    @Published var title = ""
    @Published var description = ""
    @Published var city = ""
    @Published var requisites = ""
    @Published var animal: String = "Кошка"
    @Published var image: UIImage? = nil
    @Published var isImagePickerPresented = false
    @Published var error: String? = nil
    @Published var isLoading = false
    let url = API.url.appendingPathComponent("charity").appendingPathComponent("shelter").appendingPathComponent("post")

    func post(completion: @escaping () -> () = {}, failure: @escaping () -> () = {}) {
        guard validateAllFields() else { return failure()}
        print(url)
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(AppState.shared.organisationToken ?? "")"
        ]
        let parameters: [String: Any] = [
            "title": title,
            "description": description,
            "city": city,
            "contact": requisites,
            "animal": animal
        ]
        AF.upload(multipartFormData: { multipartFormData in
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
            }
            if let image = self.image {
                multipartFormData.append(image.jpegData(compressionQuality: 0.5)!, withName: "image", fileName: "image.jpeg", mimeType: "image/jpeg")
            }
        }, to: url, method: .post, headers: headers).responseJSON { response in
            switch response.result {
            case .success:
                print(try? response.result.get())
                print("success")
                completion()
            case .failure(let error):
                print(error)
                failure()
            }
        }
    }


    func pickImage() {
        isImagePickerPresented = true
    }

    func validateAllFields() -> Bool {

        title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        description = description.trimmingCharacters(in: .whitespacesAndNewlines)
        city = city.trimmingCharacters(in: .whitespacesAndNewlines)
        requisites = requisites.trimmingCharacters(in: .whitespacesAndNewlines)


        if title.isEmpty {
            error = "Название не может быть пустым"
            return false
        }
        if description.isEmpty {
            error = "Описание не может быть пустым"
            return false
        }
        if city.isEmpty {
            error = "Город не может быть пустым"
            return false
        }
        if requisites.isEmpty {
            error = "Реквизиты не могут быть пустыми"
            return false
        }
        if image == nil {
            error = "Фото не может быть пустым"
            return false
        }
        return true
    }
    
    
}

struct NewShelterPost_Previews: PreviewProvider {
    static var previews: some View {
        NewShelterPost()
    }
}
