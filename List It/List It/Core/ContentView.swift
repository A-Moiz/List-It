//
//  ContentView.swift
//  List It
//
//  Created by Abdul Moiz on 30/03/2025.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var db = Supabase.shared
    var body: some View {
        WelcomeView(db: db)
    }
}

#Preview {
    ContentView()
}
