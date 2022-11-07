//
//  CharityFilters.swift
//  hewil
//
//  Created by vevebruh on 11/7/22.
//

import SwiftUI
import Alamofire

enum CharityFilter: String {
    case city
    
    var description: String {
        switch self {
        case .city:
            return "Город"
        }
    }
}

struct CharityFilters: View {
    @State var filters: [String: String] = [:]
    @State var doneLoading = false
    @State var cities: [String] = []
    var onSave: ([String: String]) -> Void = { _ in }
    var body: some View {
        NavigationView {
            Form {
                if doneLoading {
                    Picker(CharityFilter.city.description, selection: .init(get: {
                        return filters[CharityFilter.city.rawValue] ?? "Москва"
                    }, set: { v in
                        filters[CharityFilter.city.rawValue] = v
                    })) {
                        ForEach(cities, id: \.self) { city in
                            Text(city)
                                .tag(city)
                        }
                    }.pickerStyle(.automatic)
                } else {
                    ProgressView()
                }
            }.navigationTitle("Фильтры")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            self.onSave(filters)
                        }) {
                            Text("Сохранить")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .onAppear {
                    getInitialFilters()
                }
        }
    }
    
    func getInitialFilters() {
        let url = API.url.appendingPathComponent("charity_cities")
        AF.request(url)
            .validate()
            .responseDecodable(of: [[String: String]].self) { response in
                switch response.result {
                case .success(let cities):
                    self.cities = cities.map { $0["city"] ?? "" }
//                    self.filters[CharityFilter.city.rawValue] = (self.cities.first ?? "")
                    doneLoading = true
                case .failure(let error):
                    print(error)
                }
            }
    }
}

struct CharityFilters_Previews: PreviewProvider {
    static var previews: some View {
        CharityFilters()
    }
}
