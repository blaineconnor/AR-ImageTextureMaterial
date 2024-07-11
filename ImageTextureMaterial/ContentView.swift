//
//  ContentView.swift
//  ImageTextureMaterial
//
//  Created by Fatih Emre Sarman on 11.07.2024.
//

import SwiftUI
import RealityKit
import Combine

struct ContentView : View {
    var body: some View {
        ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

class Coordinator {
    var arView: ARView?
    var cancellable: Cancellable?
    
    func setup(){
        
        guard let arView = arView else {
            return
        }
        
        let anchor = AnchorEntity(plane: .horizontal)
        
        let mesh = MeshResource.generateBox(width: 0.3, height: 0.3, depth: 0.3, cornerRadius: 0, splitFaces: true)
        let box = ModelEntity(mesh: mesh)
        
        cancellable = TextureResource.loadAsync(named: "lola")
            .append(TextureResource.loadAsync(named: "purple_flower"))
            .append(TextureResource.loadAsync(named: "cover.jpg"))
            .append(TextureResource.loadAsync(named: "DSC_0003.JPG"))
            .append(TextureResource.loadAsync(named: "DSC_0117.JPG"))
            .append(TextureResource.loadAsync(named: "DSC_0171.JPG"))
            .collect().sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    fatalError("Unable to load texture \(error)")
                }
                self?.cancellable?.cancel()
                
            }, receiveValue: { textures in
                var materials: [UnlitMaterial] = []
                
                textures.forEach { texture in
                    var material = UnlitMaterial()
                    material.color = .init(tint: .white, texture: .init(texture))
                    materials.append(material)
                }
                
                box.model?.materials = materials
                anchor.addChild(box)
                arView.scene.addAnchor(anchor)
            }
            )
        
        
        
        
        
        //        let mesh = MeshResource.generateBox(size: 0.3)
        //        let box = ModelEntity(mesh: mesh)
        //
        //        let texture = try? TextureResource.load(named: "purple_flower")
        //
        //        if let texture = texture {
        //            var material = UnlitMaterial()
        //            material.color = .init(tint: .white, texture: .init(texture))
        //            box.model?.materials = [material]
        //        }
        //
        //        anchor.addChild(box)
        //        arView.scene.addAnchor(anchor)
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        
        context.coordinator.arView = arView
        context.coordinator.setup()
        
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}

