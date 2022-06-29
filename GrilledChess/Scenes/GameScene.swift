//
//  GameScene.swift
//  GrilledChess
//
//  Created by Matt Darveniza on 29/6/2022.
//

import Foundation
import SpriteKit

class GameScene: BoardScene {
    struct Selection {
        let position: String
        let piece: String?
        let moves: [Move]
    }
    
    var selectionIndicators: [SKNode] = []
    var selection: Selection?
    
    func clearSelection() {
        selection = nil;
        for node in selectionIndicators {
            node.removeFromParent()
        }
        
        selectionIndicators = []
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let location = touch.location(in: self)
        let (x, y) = locationToPosition(location: location)
        let positionName = positionToName(x: x, y: y)
        
        print("location: \(location.x), \(location.y)")
        print("position: \(x), \(y)")
        print("positionName: \(positionName)")
        
        if let m = selection?.moves.first(where: { move in move.to == positionName }) {
            move(to: m.san)
            clearSelection()
        } else {
            // clear previous selection
            if (selection != nil) {
                clearSelection()
            }
            
            
            if let piece = pieceAt(position: positionName) {
                selection = Selection(
                    position: positionName,
                    piece: piece,
                    moves: moveGenerator.moves(for: positionName)
                )
                highlightPiece(positionName: positionName)
            }
        }
    }
    
    func highlightPiece(positionName: String) {
        // Highlight square
        guard let square: SKSpriteNode = self.childNode(
            withName: positionName
        ) as? SKSpriteNode else { return }
        let squareHighlight = SKSpriteNode(color: SKColor(red: 0.3, green: 0.5, blue: 1, alpha: 0.5), size: square.size)
        squareHighlight.position = square.position
        squareHighlight.zPosition = Z_INDICES.squareHighlight.rawValue
        addChild(squareHighlight)
        selectionIndicators.append(squareHighlight)
        
        // Draw valid moves for piece
        let movesForPiece = moveGenerator.moves(for: positionName)
        print("moves for peice \(positionName)")
        for move in movesForPiece {
            print(move.to)
            guard let moveSquare: SKSpriteNode = self.childNode(withName: move.to) as? SKSpriteNode else { return }
            let moveIndicator = SKShapeNode(circleOfRadius: moveSquare.size.width / 6)
            moveIndicator.position = moveSquare.position
            moveIndicator.fillColor = SKColor(white: 1, alpha: 0.5)
            moveIndicator.strokeColor = SKColor.clear
            moveIndicator.zPosition = Z_INDICES.pieceMoves.rawValue
            addChild(moveIndicator)
            selectionIndicators.append(moveIndicator)
        }
        if movesForPiece.isEmpty {
            print("-");
        }
    }
    
    func move(to: String) {
        let moveResult = moveGenerator.move(to: to)
        let pieceName = "\(moveResult.color.rawValue)\((moveResult.piece.rawValue).uppercased())"
        
        guard let oldSquare = self.childNode(
            withName: moveResult.from
        ) else { return }

        guard let newSquare = self.childNode(
            withName: moveResult.to
        ) else { return }
        
        // TODO: Implement castling
        // TODO: Implement promotion
        
        self.enumerateChildNodes(withName: pieceName) {pieceNode, _ in
            if (pieceNode.position == oldSquare.position) {
                pieceNode.position = newSquare.position
            }
        }
        
        // remove opposing piece if move is an attack
        if let captured = moveResult.captured {
            let capturedPieceName = "\(moveResult.color == .w ? Move.Color.b : Move.Color.w )\(captured.uppercased())"
            
            var capturedPosition = CGPoint(x: newSquare.position.x, y: newSquare.position.y)
            // if en-passante, captured piece is one y position back or forward depending on color
            // TODO: Test this
            if (moveResult.flags.contains("e")) {
                capturedPosition.y += (moveResult.color == .w ? -squareSize.height : squareSize.height)
            }
            
            self.enumerateChildNodes(withName: capturedPieceName) {pieceNode, _ in
                if pieceNode.position == capturedPosition {
                    pieceNode.removeFromParent()
                }
            }
        }
    }
}
