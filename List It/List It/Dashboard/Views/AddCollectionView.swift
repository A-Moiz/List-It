//
//  AddCollectionView.swift
//  List It
//
//  Created by Abdul Moiz on 01/04/2025.
//

import SwiftUI

struct AddCollectionView: View {
    @State var collectionName: String = ""
    var colors: [Color] = [.red, .blue, .green, .yellow, .purple, .pink, .indigo, .mint, .orange]
    @State var selectedColor: Color = .clear
    @State var alertMessage: String = ""
    @State var showAlert: Bool = false
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Binding var collections: [Collection]
    
    var body: some View {
        NavigationStack {
            VStack {
                CustomTextField(icon: "checklist", placeholder: "Collection Name", key: $collectionName, isPassword: false)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(colors, id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Circle()
                                        .stroke(selectedColor == color ? Color.black : Color.clear, lineWidth: 8)
                                )
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                    }
                    .padding()
                }
                
                Text("Selected Color: \(selectedColor.description.capitalized)")
                    .font(.headline)
                    .foregroundColor(selectedColor == .clear ? .gray : selectedColor)
                
                Button {
                    if collectionName.isEmpty || selectedColor == .clear {
                        alertMessage = "Please enter a name and choose a color for your Collection."
                        showAlert = true
                    } else {
                        let newCollection = Collection(name: collectionName, contentCount: 5, fillColor: selectedColor)
                        collections.append(newCollection)
                        dismiss()
                    }
                } label: {
                    Text("Create Collection")
                        .padding()
                        .background(Color.orange)
                        .foregroundStyle(colorScheme == .light ? .black : .white)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .foregroundStyle(.blue)
                    }
                }
            }
            .navigationTitle("Add Collection")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $showAlert) {
                Alert(title: Text(""), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}

#Preview {
    @Previewable @State var collections = [
        Collection(name: "Today", contentCount: 10, fillColor: .orange),
        Collection(name: "Favorites", contentCount: 5, fillColor: .blue),
        Collection(name: "Work", contentCount: 8, fillColor: .green),
        Collection(name: "Personal", contentCount: 12, fillColor: .purple),
        Collection(name: "Study", contentCount: 7, fillColor: .red)
    ]
    AddCollectionView(collections: $collections)
}
