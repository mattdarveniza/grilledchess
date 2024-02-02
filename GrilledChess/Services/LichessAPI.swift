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
    
    enum Speed: String, Decodable {
        case ultraBullet, bullet, blitz, rapid, classical, correspondence, chess960, crazyhouse,
             antichess, atomic, horde, kingOfTheHill, racingKings, threeCheck
    }
    
    let gameId: String
    let fullId: String
    let color: Color
    let fen: String
    let hasMoved: Bool
    let isMyTurn: Bool
    let lastMove: String
    let speed: Speed
    
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

enum GameStateResponseType: String, Decodable, CodingKey {
    case gameFull, gameState, chatLine
}

struct BoardResponse: Decodable {
    let type: GameStateResponseType
}

struct GameEventPlayer: Decodable {
    let aiLevel: Int
    let id: String
    let name: String
    let title: String?
    let rating: Int
    let provisional: Bool
}

enum Status: String, Decodable {
    case created, started, aborted, mate, resign, stalemate, timeout, draw, outoftime, cheat,
         noStart, unknownFinish, variantEnd
}

enum PlayerColor: String, Decodable {
    case black, white
}


struct GameState: Decodable {
    let moves: String
    let wtime: Int
    let btime: Int
    let status: Status
    let winner: PlayerColor?
    let wtakeback: Bool?
    let btakeback: Bool?
}

struct GameFullEvent: Decodable {
    let id: String
    let rated: Bool
    let createdAt: Int
    let white: GameEventPlayer
    let black: GameEventPlayer
    let initialFen: String
    let state: GameState
}

struct GameStateEvent: Decodable {
    let moves: String
    let status: Status
    let winner: PlayerColor?
    let wtakeback: Bool?
    let btakeback: Bool?
    let wdraw: Bool?
    let bdraw: Bool?
}

struct ChatLineEvent: Decodable {
    enum Room: String, Decodable {
        case player, spectator
    }
    
    let room: Room
    let username: String
    let text: String
}

enum GameStateResponse: Decodable {
    case GameFullEvent, GameStateEvent, ChatLineEvent
}

final class LichessAPI<Response: Decodable, Item>: ObservableObject {
    enum LoadingState {
        case idle
        case loading
        case failed(Error)
        case loaded(Item)
    }
    
    let root = "https://lichess.org"
    let decoder = JSONDecoder()
    
    let endpoint: String
    let transformResponse: ((Response) -> Item)
    
    @Published var state = LoadingState.idle
    
    init(_ endpoint: String, transformResponse: @escaping (Response) -> Item = { $0 as! Item }) {
        self.endpoint = endpoint
        self.transformResponse = transformResponse
    }
    
    // pre-bake state for mocking/previews
    init(state: LoadingState) {
        self.endpoint = ""
        self.transformResponse = { $0 as! Item }
        self.state = state
    }

    func getRequest() -> URLRequest {
        var urlComps = URLComponents(string: root)!
        urlComps.path = "/api/\(endpoint)"
        var request = URLRequest(url: urlComps.url!)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func load() {
        state = .loading
        let request = getRequest();
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(error!)
                self.state = .failed(error!)
                // TODO: handle error
                return
            }
            
            do {
                let response = try self.decoder.decode(Response.self, from: data)
                DispatchQueue.main.async {
                    self.state = .loaded(self.transformResponse(response))
                }
            } catch let error {
                // TODO: handle error
                self.state = .failed(error)
                print(error)
                return
            }
        }
        task.resume()
    }
}
