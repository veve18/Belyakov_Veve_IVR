//
//  ShelterFilters.swift
//  hewil
//
//  Created by vevebruh on 11/7/22.
//

import SwiftUI
import Alamofire

enum ShelterFilter: String {
    case city, animal
    
    var description: String {
        switch self {
        case .city:
            return "Город"
        case .animal:
            return "Животное"
        }
    }
}

struct ShelterFilters: View {
    @State var filters: [String: String] = [:]
    @State var doneLoading = false
    @State var cities: [String] = []
    @State var animals: [String] = []
    var onSave: ([String: String]) -> Void = { _ in }
    var body: some View {
        NavigationView {
            Form {
                if doneLoading {
                    Picker(ShelterFilter.city.description, selection: .init(get: {
                        return filters[ShelterFilter.city.rawValue] ?? "Москва"
                    }, set: { v in
                        filters[ShelterFilter.city.rawValue] = v
                    })) {
                        ForEach(cities, id: \.self) { city in
                            Text(city)
                                .tag(city)
                        }
                    }.pickerStyle(.automatic)
                    
                    Picker(ShelterFilter.animal.description, selection: .init(get: {
                        return filters[ShelterFilter.animal.rawValue] ?? "Кошка"
                    }, set: { v in
                        filters[ShelterFilter.animal.rawValue] = v
                    })) {
                        ForEach(animals, id: \.self) { animal in
                            Text(animal)
                                .tag(animal)
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
        let url = API.url.appendingPathComponent("animal_shelter_cities")
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
        
        let url2 = API.url.appendingPathComponent("animal_shelter_animals")
        AF.request(url2)
            .validate()
            .responseDecodable(of: [[String: String]].self) { response in
                switch response.result {
                case .success(let animals):
                    self.animals = animals.map { $0["animal"] ?? "" }
//                    self.filters[CharityFilter.city.rawValue] = (self.cities.first ?? "")
                    
                    doneLoading = true
                case .failure(let error):
                    print(error)
                }
            }
    }
}

struct ShelterFilters_Previews: PreviewProvider {
    static var previews: some View {
        ShelterFilters()
    }
}
