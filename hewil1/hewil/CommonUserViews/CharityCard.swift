//
//  CharityCard.swift
//  hewil
//
//  Created by vevebruh on 10/30/22.
//

import Foundation

struct CharityPost: Codable, Equatable, Identifiable {
    let id: Int
    var title: String = ""
    var description: String? = nil
    var charityOrganisationId: Int? = nil
    var charityOrganisationTitle: String? = nil
    var requisites: String? = nil
    var image: String = ""
    var city: String? = nil
    var isPhysical: Bool? = false
}
