//
//  LiChessAPIService.swift
//  GrilledChess
//
//  Created by Matt Darveniza on 28/6/2022.
//

import Foundation

struct Opponent: Decodable {
    let id: String
    let rating: Int
    let username: String
}

struct PlayedGame: Decodable, Identifiable {
    enum Color: String, Decodable {
        case white, black
    }
    
    let gameId: String
    let fullId: String
    let color: Color
    let fen: String
    let hasMoved: Bool
    let isMyTurn: Bool
    let lastMove: String
    
    let opponent: Opponent
    let secondsLeft: Int
    
    var id: String {
        get {
            return gameId
        }
    }
}

struct NowPlayingResponse: Decodable {
    let nowPlaying: [PlayedGame]
}

final class LichessAPI: ObservableObject {
    let root = "https://lichess.org"
    let decoder = JSONDecoder()
    
    @Published var games: [PlayedGame] = []
    
    func getRequest(path: String) -> URLRequest {
        var urlComps = URLComponents(string: root)!
        urlComps.path = "/api/\(path)"
        var request = URLRequest(url: urlComps.url!)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func loadGames() -> URLSessionDataTask {
        let request = getRequest(path: "account/playing");
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(error!)
                // TODO: handle error
                return
            }
            
            do {
                let response = try self.decoder.decode(NowPlayingResponse.self, from: data)
                self.games = response.nowPlaying
            } catch let error {
                // TODO: handle error
                print(error)
            }
        }
        task.resume()
        return task
    }
}
