//
//  ContentView.swift
//  List It
//
//  Created by Abdul Moiz on 30/03/2025.
//

import SwiftUI

struct ContentView: View {
    // MARK: - Properties
    @StateObject private var db = Supabase.shared
    @StateObject private var helper = Helper.sharedHelper
    @AppStorage("isSignedIn") var isSignedIn: Bool = false
    
    var body: some View {
        if !isSignedIn {
            WelcomeView(db: db, helper: helper)
        } else {
            AllListsView(helper: helper, db: db)
                .onAppear {
                    fetchingAllData()
                }
                .alert(isPresented: $helper.showAlert) {
                    Alert(title: Text(""), message: Text(helper.alertMessage), dismissButton: .default(Text("OK")))
                }
        }
    }
    
    func fetchingAllData() {
        db.fetchCurrentUser { success, error in
            if !success {
                helper.showAlertWithMessage("Error fetching User details: \(error ?? "Unknown error")")
            }
        }
        db.fetchUserLists { success, errorMessage in
            if !success, let error = errorMessage {
                helper.showAlertWithMessage("Error fetching user Lists: \(error)")
            }
        }
        db.fetchUserCollections { success, errorMessage in
            if !success, let error = errorMessage {
                helper.showAlertWithMessage("Error fetching Collections: \(error)")
            }
        }
        db.fetchUserTasks { success, errorMessage in
            if !success, let error = errorMessage {
                helper.showAlertWithMessage("Error fetching and displaying new Task: \(error)")
            }
        }
        db.fetchUserNotes { success, errorMessage in
            if !success, let error = errorMessage {
                helper.showAlertWithMessage("Error fetching and displaying new Note: \(error)")
            }
        }
    }
}

//#Preview {
//    ContentView()
//}
