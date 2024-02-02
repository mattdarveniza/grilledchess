//
//  ContentView.swift
//  GrilledChess
//
//  Created by Matt Darveniza on 30/10/21.
//

import SwiftUI
import SpriteKit

struct GameView: View {
    let game: PlayedGame
//    let gameStateApi: LichessAPI<>
    
    init(game: PlayedGame) {
        self.game = game
//        self.gameStateApi = LichessAPI("board/game/stream/\(game.gameId)")
    }
    
    var scene: SKScene {
        let scene = GameScene(
            gameFen: game.fen,
            orientation: game.color == .white ? .white : .black
        )

        scene.size = CGSize(width: 300, height: 300)
        scene.scaleMode = .resizeFill
        scene.name = "board"
        scene.backgroundColor = .green

        return scene
    }

    var body: some View {
        SpriteView(scene: scene)
            .frame(width: 300, height: 300)
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
