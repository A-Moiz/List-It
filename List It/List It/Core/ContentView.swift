//
//  ContentView.swift
//  List It
//
//  Created by Abdul Moiz on 30/03/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var db = Supabase.shared
    @StateObject private var helper = Helper.sharedHelper
    var body: some View {
        DashboardView(helper: helper, db: db)
        // WelcomeView(db: db, helper: helper)
    }
}

#Preview {
    ContentView()
}
