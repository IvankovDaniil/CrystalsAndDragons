//
//  Player.swift
//  CrystalsAndDragons
//
//  Created by Даниил Иваньков on 25.06.2025.
//

struct Player {
    var position: Position
    var inventory: [Item]
    var gold: Int = 0
    var remaingSteps: Int
    
    mutating func move(to direction: Directions) {
        self.position = self.position.move(to: direction)
    }
}
