//
//  MapListView.swift
//  SwiftUILegandLogger
//
//  Created by Laura Hart on 5/1/24.
//

import SwiftUI
import CoreData
import PhotosUI

struct MapListView: View {
    @State private var maps: [Maps] = Persistence.shared.fetchMaps()
    @State private var photosPickerItem: PhotosPickerItem?
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedImage: UIImage?
    @State private var showMapEditor = false
    @State private var selectedMap: Maps?
    @State private var showPhotoPicker = false
    @State var needsRefresh = false
    
    var body: some View {
        NavigationStack {
            listView
                .navigationTitle("Game Maps")
                .toolbar { addPhotoButton }
                .photosPicker(isPresented: $showPhotoPicker, selection: $photosPickerItem, matching: .images)
                .onChange(of: photosPickerItem) { processPhotoPickerItem(newItem: $0) }
                .navigationDestination(isPresented: $showMapEditor) {
                    mapEditorDestination()
                }
                .onAppear { refreshMaps() }
                .onChange(of: needsRefresh) { _ in
                    if needsRefresh {
                        refreshMaps()
                        needsRefresh = false // Reset the refresh flag
                    }
                }
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .active {
                        refreshMaps()
                    }
                }
        }
    }
    
    private var listView: some View {
        List(maps, id: \.self) { map in
            navigationLinkForRow(map)
        }
    }
    
    private func navigationLinkForRow(_ map: Maps) -> some View {
        NavigationLink(destination: mapEditorView(map: map)) {
            mapRow(map: map)
        }
        .swipeActions {
            deleteAction(map: map)
        }
    }
    
    private var addPhotoButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: { showPhotoPicker = true }) {
                Label("Add Photo", systemImage: "plus")
            }
        }
    }
    
    private func mapRow(map: Maps) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(map.mapName ?? "Unknown Map")
                .fontWeight(.semibold)
                .minimumScaleFactor(0.5)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(1), radius: 5)
            Text(map.date?.formatted(date: .abbreviated, time: .shortened) ?? "N/A")
                .fontWeight(.light)
                .minimumScaleFactor(0.25)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(1), radius: 5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 20)
        .background(backgroundView(for: map))
        .scaledToFill()
    }
    
    private func deleteAction(map: Maps) -> some View {
        Button(role: .destructive) {
            Persistence.shared.deleteMap(map: map)
            refreshMaps()
        } label: {
            Label("Delete", systemImage: "trash.fill")
        }
    }
    
    private func backgroundView(for map: Maps) -> some View {
        Group {
            if let data = map.mapImage, let image = UIImage(data: data) {
                Image(uiImage: image).resizable()
                    .blur(radius: 20)
                    .aspectRatio(contentMode: .fill)
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .clipped()
            } else {
                Color.green  // Fallback color if no image
            }
        }
    }
    
    @ViewBuilder
    private func mapEditorView(map: Maps) -> some View {
        MapEditor(map: map, id: map.id, mapImage: map.mapImage.flatMap { UIImage(data: $0) } ?? UIImage(), locked: true, newMap: false, needsRefresh: $needsRefresh)
    }
    
    private func refreshMaps() {
        maps = Persistence.shared.fetchMaps()
    }
    
    private func processPhotoPickerItem(newItem: PhotosPickerItem?) {
        guard let newItem = newItem else { return }
        newItem.loadTransferable(type: Data.self) { result in
            switch result {
            case .success(let data):
                if let data = data, let image = UIImage(data: data) {
                    selectedImage = image
                    let mapName = "New Map"
                    let newMap = Persistence.shared.addPhoto(photo: image, name: mapName)
                    selectedMap = newMap
                    showMapEditor = true // Trigger the navigation to MapEditor
                    photosPickerItem = nil // Reset picker item
                } else {
                    print("Failed to load image data.")
                }
            case .failure(let error):
                print("Error loading image data: \(error.localizedDescription)")
            }
        }
    }
    
    @ViewBuilder
    private func mapEditorDestination() -> some View {
        if let selectedMap = selectedMap {
            MapEditor(map: selectedMap, id: selectedMap.id, mapImage: selectedImage ?? UIImage(), locked: false, newMap: false, needsRefresh: $needsRefresh)
        } else if let selectedImage = selectedImage {
            MapEditor(map: nil, id: nil, mapImage: selectedImage, locked: false, newMap: true, needsRefresh: $needsRefresh)
        }
    }
}
