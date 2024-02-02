//
//  ContentView.swift
//  GrilledChess
//
//  Created by Matt Darveniza on 30/10/21.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    @ObservedObject var gamesApi = LichessAPI("account/playing"){ (response: NowPlayingResponse) in
        let games = response.nowPlaying
        return games.filter { game in game.speed == .correspondence }
    }
    
    var body: some View {
        NavigationView {
            switch gamesApi.state {
            case .idle:
                Color.clear.onAppear(perform: gamesApi.load)
            case .loading:
                ProgressView()
            case .failed:
                VStack {
                    Text("An error occured")
                    Button(action: gamesApi.load) {
                        Text("Reload")
                    }
                }
            case .loaded(let games):
                GamesList(games: games)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(gamesApi: LichessAPI(state: .loaded(mockGames)))
    }
}
