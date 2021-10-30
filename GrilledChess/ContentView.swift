//
//  ContentView.swift
//  GrilledChess
//
//  Created by Matt Darveniza on 30/10/21.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    
    var scene: SKScene {
        let scene = BoardScene()
        scene.size = CGSize(width: 256, height: 256)
        scene.scaleMode = .resizeFill
        scene.name = "board"
        scene.backgroundColor = .green
        
        return scene
    }
    
    var body: some View {
        SpriteView(scene: scene)
            .frame(width: 256, height: 256)
            .background(Color.red)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
