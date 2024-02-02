//
//  GamesList.swift
//  GrilledChess
//
//  Created by Matt Darveniza on 29/6/2022.
//

import SwiftUI

struct GamesList: View {
    let games: [PlayedGame]
    let yourTurnCount: Int
    
    init(games: [PlayedGame]) {
        self.games = games.sorted { (a, b) in
            guard a.isMyTurn == b.isMyTurn else {
                return a.isMyTurn
            }
            return a.secondsLeft > b.secondsLeft
        }
        
        yourTurnCount = games.filter { game in game.isMyTurn }.count
    }
    
    var body: some View {
        NavigationStack {
            List(games) { game in
                NavigationLink {
                    GameView(game: game)
                } label: {
                    GameRow(game: game).frame(height: 70)
                }.listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 15))
            }
        }.navigationTitle("Games (\(yourTurnCount))")
    }
}

struct GamesList_Previews: PreviewProvider {
    static var previews: some View {
        GamesList(games: mockGames)
    }
}
