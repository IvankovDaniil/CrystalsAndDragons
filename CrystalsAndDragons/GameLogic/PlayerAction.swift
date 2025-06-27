//
//  PlayerAction.swift
//  CrystalsAndDragons
//
//  Created by Даниил Иваньков on 27.06.2025.
//

enum PlayerAction {
    case move(Directions)
    case get
    case drop(Item)
    case open
    case invalid
    
    init(input: String) {
        switch input {
        case "N", "S", "E", "W": self = .move(Directions(rawValue: input)!)
        case "get": self = .get
        case "drop key": self = .drop(.key)
        case "drop torch": self = .drop(.torch)
        case "open": self = .open
        default: self = .invalid
        }
    }
}
