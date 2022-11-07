//
//  CharityPostCard.swift
//  hewil
//
//  Created by vevebruh on 10/30/22.
//

import SwiftUI

struct CharityPostCard: View {
    var post: CharityPost

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AsyncImage(url: try? post.image.asURL()) { img in
                if let image = img.image {
                    image
                        .resizable()
                } else {
                    Rectangle()
                        .fill(LinearGradient(colors: [.blue, .blue.opacity(0.6)], startPoint: .bottomLeading, endPoint: .topTrailing))
                }
            }.frame(height: 200)
            VStack(alignment: .leading) {
                Text("\(post.charityOrganisationTitle ?? "фонд поддержки котиков")")
                    .font(.caption.smallCaps())
                    .foregroundColor(Color(uiColor: .systemGray4))
                Text(post.title)
                    .font(.title.bold())
            }.padding()
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .background(RoundedRectangle(cornerRadius: 20).stroke(Color(uiColor: .systemGray4), lineWidth: 1))
    }
}

struct CharityPostCard_Previews: PreviewProvider {
    static var previews: some View {
        CharityPostCard(post: .init(id: 0, title: "Testing it out")).padding()
    }
}
