//
//  ShelterPost.swift
//  hewil
//
//  Created by vevebruh on 10/31/22.
//

import Foundation

struct ShelterPost: Identifiable, Codable {
    let id: Int
    var title: String = ""
    var description: String? = nil
    var charityOrganisationId: Int? = nil
    var charityOrganisationTitle: String? = nil
    var contact: String? = nil
    var image: String? = nil
    var city: String? = nil
    var animal: String? = nil
}
