//
//  MockData.swift
//  GrilledChess
//
//  Created by Matt Darveniza on 29/6/2022.
//

import Foundation

let mockGames = [
    PlayedGame(
        gameId: "abc",
        fullId: "abc",
        color: .white,
        fen: "r3kb1r/pp1nqppp/2p2n2/4p3/2BPP1b1/1QP2N2/PP4PP/RNB1K2R w KQkq - 3 9",
        hasMoved: true,
        isMyTurn: true,
        lastMove: "d8e7",
        speed: .correspondence,
        opponent: Opponent(id: "foo", rating: 1500, username: "foo"),
        secondsLeft: 60 * 60 * 12 + 5 * 60 + 30 // 12h 5m 30s
    ),
    PlayedGame(
        gameId: "def",
        fullId: "def",
        color: .white,
        fen: "6k1/2r5/p1P1KR2/8/pP1N4/P7/8/8 w - - 22 72",
        hasMoved: true,
        isMyTurn: true,
        lastMove: "g7g8",
        speed: .correspondence,
        opponent: Opponent(id: "foo", rating: 1500, username: "foo"),
        secondsLeft: 119946
    ),
    PlayedGame(
        gameId: "ghi",
        fullId: "ghi",
        color: .white,
        fen: "rnbqkbnr/ppp1pppp/8/8/4p3/2N2P2/PPPP2PP/R1BQKBNR b KQkq - 0 3",
        hasMoved: true,
        isMyTurn: false,
        lastMove: "f2f3",
        speed: .correspondence,
        opponent: Opponent(id:"foo", rating: 1500, username: "foo"),
        secondsLeft: 172800
    )
]
