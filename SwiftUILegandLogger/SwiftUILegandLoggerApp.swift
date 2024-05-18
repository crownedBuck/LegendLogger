//
//  SwiftUILegandLoggerApp.swift
//  SwiftUILegandLogger
//
//  Created by Laura Hart on 4/30/24.
//

import SwiftUI

@main
struct SwiftUILegandLoggerApp: App {
    let persistenceController = Persistence.shared

    var body: some Scene {
        WindowGroup {
            MapListView()
                .environment(\.managedObjectContext, persistenceController.persistentContainer.viewContext)
        }
    }
}
