//
//  ContentView.swift
//  GrilledChess
//
//  Created by Matt Darveniza on 30/10/21.
//

import SwiftUI
import SpriteKit

struct GameView: View {
    var scene: SKScene {
        let scene = GameScene()
        scene.size = CGSize(width: 300, height: 300)
        scene.scaleMode = .resizeFill
        scene.name = "board"
        scene.backgroundColor = .green

        return scene
    }

    var body: some View {
        SpriteView(scene: scene)
            .frame(width: 300, height: 300)
            .background(Color.red)
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
