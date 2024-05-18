//
//  MapEditor.swift
//  SwiftUILegandLogger
//
//  Created by Laura Hart on 5/1/24.
//
//
//  MapEditor.swift
//  SwiftUILegandLogger
//
//  Created by Laura Hart on 5/1/24.
//

import SwiftUI
import CoreData
import PhotosUI

struct MapEditor: View {
    @State private var mapImage: UIImage
    @State private var map: Maps?
    @State private var circles: [CircleData] = []
    @State private var locked: Bool
    @State private var id: UUID?
    @State private var title: String = "My Map"
    @State private var isShowingRenameAlert = false
    @State private var userInput: String = ""
    @GestureState private var pinchScale: CGFloat = 1.0
    @State private var selectedCircleIndex: Int? = nil
    @State private var newMap = true
    @Binding var needsRefresh: Bool
    @State private var circleBrain = CircleBrain.shared
    @Environment(\.managedObjectContext) private var viewContext

    init(map: Maps?, id: UUID?, mapImage: UIImage, locked: Bool, newMap: Bool, needsRefresh: Binding<Bool>) {
        self._map = State(initialValue: map)
        self._mapImage = State(initialValue: mapImage)
        self._locked = State(initialValue: locked)
        self._newMap = State(initialValue: newMap)
        self._needsRefresh = needsRefresh
    }
    
    var body: some View {
        ZStack {
            Image(uiImage: mapImage)
                .resizable()
                .scaledToFill()
                
            ForEach(circles.indices, id: \.self) { index in
                DraggableCircle(circle: $circles[index], locked: locked, isSelected: index == selectedCircleIndex)
                    .onTapGesture {
                        if !locked {
                            selectedCircleIndex = index
                            print("Selected circle at index \(index): \(circles[selectedCircleIndex!])")
                        }
                    }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(title) {
                    userInput = title
                    isShowingRenameAlert = true
                }
                .onChange(of: title) { newValue in
                    if !newMap, let map = map {
                        Persistence.shared.editMapName(id: map.objectID, newTitle: newValue)
                    }
                }
                Button(action: {
                    if !locked {
                        addNewCircle()
                    }
                }, label: {
                    Text("\(Image(systemName: "person.badge.plus"))")
                })
                Button(action: {
                    toggleLock()
                }, label: {
                    Image(systemName: locked ? "lock" : "lock.open")
                })
            }
        }
        .magnifyCircle(locked: $locked, selectedCircleIndex: $selectedCircleIndex, circles: $circles, pinchScale: _pinchScale)
        .sheet(isPresented: $isShowingRenameAlert) {
            RenameAlertView(userInput: $userInput, isPresented: $isShowingRenameAlert) {
                title = userInput
                print("New title: \(title)")
            }
        }
        .onAppear {
            loadImage()
            if newMap, map == nil {
                map = Maps(context: viewContext)
                map?.mapImage = mapImage.pngData()
                map?.mapName = title
                Persistence.shared.saveContext()
                newMap.toggle()
            } else if let map = map {
                title = map.mapName ?? "My Map"
                loadCharacters(for: map)
            }
        }
        .onDisappear {
            needsRefresh = true
        }
    }

    private func addNewCircle() {
        var newCircle = CircleData(position: CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY),
                                   color: generateRandomColor(), size: 100)
        let circleColor = newCircle.color.uiColor
        let circlePosition = newCircle.position

        if let character = Persistence.shared.saveCharacter(context: viewContext,
                                                            positionX: Float(circlePosition.x),
                                                            positionY: Float(circlePosition.y),
                                                            colorA: Float(circleColor.components.alpha),
                                                            colorR: Float(circleColor.components.red),
                                                            colorG: Float(circleColor.components.green),
                                                            colorB: Float(circleColor.components.blue),
                                                            size: Float(newCircle.size),
                                                            id: map!.id!) {
            newCircle.character = character
            circles.append(newCircle)
        } else {
            print("Failed to save character.")
        }
    }

    private func generateRandomColor() -> Color {
        Color(red: Double.random(in: 0...1), green: Double.random(in: 0...1), blue: Double.random(in: 0...1))
    }

    func toggleLock() {
        locked.toggle()
    }

    private func saveMapName() {
        guard let map = map else { return }
        Persistence.shared.editMapName(id: map.objectID, newTitle: title)
    }

    private func loadImage() {
        if !newMap, let imageData = map?.mapImage {
            if let image = UIImage(data: imageData) {
                self.mapImage = image
            } else {
                print("Failed to convert data to UIImage.")
            }
        } else {
            print("Image data is nil or new map flag is true.")
        }
    }

    private func loadCharacters(for map: Maps) {
        let characters = Persistence.shared.fetchCharacters(for: map)
        circles = characters.map { character in
            let position = CGPoint(x: CGFloat(character.characterLocationX), y: CGFloat(character.characterLocationY))
            let color = UIColor(red: CGFloat(character.characterColorR), green: CGFloat(character.characterColorG), blue: CGFloat(character.characterColorB), alpha: CGFloat(character.characterColorA))
            return CircleData(position: position, color: Color(color), size: CGFloat(character.characterSize), character: character)
        }
        print("Loaded characters: \(circles)")
    }
}

struct CircleData: Identifiable {
    var id = UUID()
    var position: CGPoint
    var color: Color
    var size: CGFloat
    var character: Characters?
}

struct DraggableCircle: View {
    @Binding var circle: CircleData
    var locked: Bool
    var isSelected = true
    
    var body: some View {
        Circle()
            .fill(circle.color)
            .frame(width: circle.size, height: circle.size)
            .overlay(
                isSelected ? Circle().stroke(Color.black.opacity(0.5), lineWidth: 2) : nil
            )
            .position(circle.position)
            .if(!locked) { view in
                view.gesture(
                    DragGesture()
                        .onChanged { gesture in
                            circle.position = gesture.location
                        }
                        .onEnded { _ in
                            print("drag has ended")
                            if let character = circle.character {
                                print("Updating character with new position: \(circle.position)")
                                Persistence.shared.updateCharacter(character: character, newPosition: circle.position, newSize: circle.size)
                            } else {
                                print("Character is nil for circle at position \(circle.position)")
                            }
                        }
                )
            }
    }
}

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

extension Color {
    var uiColor: UIColor {
        let components = UIColor(self).components
        return UIColor(red: components.red, green: components.green, blue: components.blue, alpha: components.alpha)
    }
}

extension View {
    func magnifyCircle(locked: Binding<Bool>, selectedCircleIndex: Binding<Int?>, circles: Binding<[CircleData]>, pinchScale: GestureState<CGFloat>) -> some View {
        self.gesture(
            !locked.wrappedValue && selectedCircleIndex.wrappedValue != nil ? MagnificationGesture()
                .updating(pinchScale) { value, state, _ in
                    state = value
                }
                .onEnded { value in
                    if let index = selectedCircleIndex.wrappedValue {
                        circles.wrappedValue[index].size *= value
                        if let character = circles.wrappedValue[index].character {
                            print("Updating character with new size: \(circles.wrappedValue[index].size)")
                            Persistence.shared.updateCharacter(character: character, newPosition: circles.wrappedValue[index].position, newSize: circles.wrappedValue[index].size)
                        } else {
                            print("Character is nil for circle at index \(index) with size \(circles.wrappedValue[index].size)")
                        }
                    }
                } : nil
        )
    }
}

