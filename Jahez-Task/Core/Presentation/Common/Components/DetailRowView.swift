//
//  DetailRowView.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 19/08/2025.
//

import SwiftUI

struct DetailRowView: View {
    let title: String
    let value: String
    let isLink: Bool
    
    init(title: String, value: String, isLink: Bool = false) {
        self.title = title
        self.value = value
        self.isLink = isLink
    }
    
    var body: some View {
        HStack(alignment: .top) {
            Text(title + ":")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            
            if isLink, let url = URL(string: value) {
                Link(value, destination: url)
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .multilineTextAlignment(.leading)
            } else {
                Text(value)
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
    }
}
