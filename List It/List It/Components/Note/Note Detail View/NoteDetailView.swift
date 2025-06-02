//
//  NoteView.swift
//  List It
//
//  Created by Abdul Moiz on 08/04/2025.
//

import SwiftUI

struct NoteDetailView: View {
    // MARK: - Properties
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @Binding var note: Note
    @Binding var collection: Collection
    @ObservedObject var db: Supabase
    @ObservedObject var helper: Helper
    @State private var editedTitle: String = ""
    @State private var editedDescription: String = ""
    @State private var selectedColorHex: String = ""
    @State private var animateContent: Bool = false
    @State private var circleData: [CircleModel] = []
    @State private var timer: Timer?

    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: Background
                LinearGradient(
                    colors: [
                        colorScheme == .dark ? Color(UIColor.systemBackground).opacity(0.3) : Color(UIColor.systemBackground),
                        colorScheme == .dark ? Color.black.opacity(0.9) : Color(UIColor.systemBackground).opacity(0.9)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .overlay(
                    ZStack {
                        ForEach(circleData) { circle in
                            Circle()
                                .fill(note.bgColor.opacity(colorScheme == .dark ? 0.2 : 0.5))
                                .frame(width: circle.size)
                                .position(x: circle.x, y: circle.y)
                                .animation(.easeInOut(duration: 2.0), value: circle.x)
                        }
                    }
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 22) {
                        // MARK: - Note title field
                        NoteTitleView(editedTitle: $editedTitle, selectedColorHex: $selectedColorHex, animateContent: $animateContent)
                        
                        // MARK: - Description editor
                        NoteDescriptionView(editedDescription: $editedDescription, selectedColorHex: $selectedColorHex, animateContent: $animateContent)
                        
                        // MARK: - Color option for note
                        VStack(spacing: 8) {
                            Text("Note Color")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 2)

                            ColorSelectionView(colorHexes: AppConstants.listColorHexes, selectedHex: $selectedColorHex)
                                .padding(.vertical, 8)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                        
                        // MARK: - Note metadata card
                        NoteMetadataCardView(note: $note, selectedColorHex: $selectedColorHex, collection: $collection, animateContent: $animateContent, db: db, helper: helper)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                        
                        // MARK: - Save button
                        Button {
                            withAnimation {
                                db.updateNote(note: note, title: editedTitle, description: editedDescription, selectedColorHex: selectedColorHex) { success, error in
                                    if !success, let errorMessage = error {
                                        helper.showAlertWithMessage("Error updating Note: \(errorMessage)")
                                    } else {
                                        db.fetchUserNotes { success, errorMessage in
                                            if !success, let error = errorMessage {
                                                helper.showAlertWithMessage("Error fetching new updated Note: \(error)")
                                            } else {
                                                dismiss()
                                            }
                                        }
                                    }
                                }
                            }
                        } label: {
                            Text("Save Changes")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [Color(hex: selectedColorHex), Color(hex: selectedColorHex).opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: Color(hex: selectedColorHex).opacity(0.3), radius: 5, x: 0, y: 2)
                        }
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                    }
                    .padding()
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("")
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 4) {
                        Text("Note Details")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Created: \(db.dateFormatterWithoutTime(note.createdAt))")
                            .font(.caption)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(colorScheme == .dark ? Color.gray : Color.gray.opacity(0.7))
                    }
                }
            }
            .onAppear {
                editedTitle = note.title
                editedDescription = note.description ?? ""
                selectedColorHex = note.bgColorHex
                generateRandomCircles()
                
                timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
                    withAnimation(.easeInOut(duration: 2.0)) {
                        generateRandomCircles()
                    }
                }
                
                withAnimation(.easeOut(duration: 0.4)) {
                    animateContent = true
                }
            }
            .onDisappear {
                timer?.invalidate()
            }
            .alert(isPresented: $helper.showAlert) {
                Alert(title: Text(""), message: Text(helper.alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    // MARK: - Function for background
    func generateRandomCircles() {
        circleData = (0..<15).map { _ in
            CircleModel(
                size: CGFloat.random(in: 50...200),
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
            )
        }
    }
}

//#Preview {
//    @Previewable @State var note = Note(id: UUID().uuidString, title: "Testing", description: "Testing note component", isDeleted: false, bgColorHex: "#87CEEB", isPinned: false, collectionID: "", userID: "", listID: "")
//    @Previewable @State var collection = Collection(id: UUID().uuidString, collectionName: "", bgColorHex: "", isDefault: false, listID: "", userID: "")
//    NoteDetailView(note: $note, collection: $collection, db: Supabase(), helper: Helper())
//}
