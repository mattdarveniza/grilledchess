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
                Text("\(game.opponent.username) (\(game.opponent.rating))")
                    .font(.headline)
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
        GameRow(game: mockGames[0]).previewLayout(.fixed(width: 300, height: 70))
    }
}
