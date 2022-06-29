//
//  GameRow.swift
//  GrilledChess
//
//  Created by Matt Darveniza on 28/6/2022.
//

import Foundation
import SwiftUI

struct GameRow: View {
    var game: PlayedGame
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(game.opponent.username)
                    .font(.title)
                    .multilineTextAlignment(.leading)
                HStack {
                    Text(game.isMyTurn ? "Your Turn" : "Their Turn")
                    Spacer()
                    Text("Next Turn: \(nextTurn())")
                }.font(.caption)
            }.padding([.top, .leading, .bottom])
            BoardPreview(gameFen: game.fen, orientation: game.color == .white ? .white : .black)
                .padding(5)
        }
    }
    
    func nextTurn() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: TimeInterval(game.secondsLeft))!
    }
}

struct GameRow_Previews: PreviewProvider {
    static var previews: some View {
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
        )).previewLayout(.fixed(width: 300, height: 70))
    }
}
