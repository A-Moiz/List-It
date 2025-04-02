//
//  ContentView.swift
//  List It
//
//  Created by Abdul Moiz on 30/03/2025.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var db = Supabase.shared
    @ObservedObject private var helper = Helper.sharedHelper
    var body: some View {
        // DashboardView()
        WelcomeView(db: db, helper: helper)
    }
}

#Preview {
    ContentView()
}
