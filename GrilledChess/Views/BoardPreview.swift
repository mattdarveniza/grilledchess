//
//  BoardPreview.swift
//  GrilledChess
//
//  Created by Matt Darveniza on 29/6/2022.
//

import SpriteKit
import SwiftUI

struct BoardPreview: View {
    var gameFen: String
    var orientation: BoardScene.Orientation
    
    var scene: SKScene {
        let scene = BoardScene(gameFen: gameFen, orientation: orientation)
        scene.scaleMode = .resizeFill
        scene.name = "boardPreview"
        scene.backgroundColor = .green
        
        return scene
    }
    
    var body: some View {
        SpriteView(scene: scene)
            .aspectRatio(1.0, contentMode: .fit)
    }
}

struct BoardPreview_Previews: PreviewProvider {
    static var previews: some View {
        BoardPreview(gameFen: "", orientation: BoardScene.Orientation.white).previewLayout(.sizeThatFits)
    }
}
