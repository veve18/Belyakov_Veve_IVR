//
//  NewCharityPost.swift
//  hewil
//
//  Created by vevebruh on 11/2/22.
//

import SwiftUI
import Combine
import Alamofire

struct NewCharityPost: View {
    @StateObject private var data = NewPostData()
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
                TextField("Реквизиты / контакты", text: $data.requisites)
            }
            Section {
                Toggle(isOn: $data.isPhysical, label: {
                    Text("Физическая помощь")
                })
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
                        if data.isLoading {
                            ProgressView()
                        } else {
                            Image(systemName: "plus")
                        }
                        Text("Создать пост")
                    }.foregroundColor(.blue)
                }
                
            }
        }.sheet(isPresented: $data.isImagePickerPresented, onDismiss: {}) {
            ImagePickerSheet(image: $data.image)
        }
    }
}

struct ImagePickerSheet: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerSheet
        
        init(_ parent: ImagePickerSheet) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}



class NewPostData: ObservableObject {
    @Published var title = ""
    @Published var description = ""
    @Published var city = ""
    @Published var requisites = ""
    @Published var isPhysical = false
    @Published var image: UIImage? = nil
    @Published var isImagePickerPresented = false
    @Published var error: String? = nil
    @Published var isLoading: Bool = false
    let url = API.url.appendingPathComponent("charity").appendingPathComponent("post")

    func post(completion: @escaping () -> () = {}, failure: @escaping () -> () = {}) {
        guard validateAllFields() else { return failure()}
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(AppState.shared.organisationToken ?? "")"
        ]
        let parameters: [String: Any] = [
            "title": title,
            "description": description,
            "city": city,
            "requisites": requisites,
            "isPhysical": isPhysical
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
            // Check status code to be in 200..<300
                if let statusCode = response.response?.statusCode {
                    if statusCode >= 200 && statusCode < 300 {
                        completion()
                        print("Success")
                    } else {
                        self.error = "Ошибка сервера. Возможно, ваш аккаунт не подтвержден."
                        failure()
                    }
                }
            case .failure(let error):
                print(error)
                self.error = "Ошибка сервера. Возможно, ваш аккаунт не подтвержден."
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

struct NewCharityPost_Previews: PreviewProvider {
    static var previews: some View {
        NewCharityPost()
    }
}
