//
//  ContentView.swift
//  GrilledChess
//
//  Created by Matt Darveniza on 30/10/21.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    var body: some View {
        GameRow(game: PlayedGame(
            gameId: "abc",
            fullId: "abc",
            color: PlayedGame.Color.white,
            fen: "r3kb1r/pp1nqppp/2p2n2/4p3/2BPP1b1/1QP2N2/PP4PP/RNB1K2R w KQkq - 3 9",
            hasMoved: true,
            isMyTurn: true,
            lastMove: "d8e7",
            opponent: Opponent(id: "foo", rating: 1500, username: "foo"),
            secondsLeft: 60 * 60 * 12 + 5 * 60 + 30 // 12h 5m 30s
        ))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
