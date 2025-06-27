//
//  Dungeon.swift
//  CrystalsAndDragons
//
//  Created by Даниил Иваньков on 25.06.2025.
//
import Foundation

class Dungeon {
    var numberOfRooms = -1
    var map = [[Room]]()
    private var isHaveKey = false
    private var isHaveChest = false
    
    //Создание карты
    func generateMap() {
        let (rows, cols) = calculateMatrixSize(for: numberOfRooms)
        var roomsCount = 0
        
        map = Array(repeating: [], count: rows)
        
        for x in 0 ..< rows {
            for y in 0 ..< cols {
                if roomsCount >= numberOfRooms {
                    continue
                }
                
                var isDark = chanceOfDarkRoom()
                let item = fillRoom(isDark: &isDark, roomsCount: roomsCount)
                let pos = Position(x: x + 1, y: y + 1)
                let room = Room(position: pos, item: item, isDark: isDark)
                map[x].append(room)
                roomsCount += 1
            }
        }
    }
    
    
    //Вспомогательный метод для лога карты
    func printMap() {
        print("=== Dungeon Map ===")
        for (i, row) in map.enumerated() {
            var rowLog = ""
            for room in row {
                let symbol: String
                switch room.item {
                case .some(.gold(_)):
                    symbol = "💰"
                case .some(.torch):
                    symbol = "🕯️"
                case .some(.key):
                    symbol = "🗝️"
                case .some(.chest):
                    symbol = "📦"
                case .none:
                    symbol = "▫️"
                case .graile: symbol = "123"
                }
                let cell = room.isDark ? "🌑" + symbol : symbol
                rowLog += cell + " "
            }
            print("Row \(i + 1): \(rowLog)")
        }
        print("====================")
    }
    
    
    //Наполнение комнаты
    //20 что комната пустая
    //100 процентов, что в последних двух комнтах будет ключ с сундуком в светлых комнатах(если их еще не было)
    private func fillRoom(isDark: inout Bool, roomsCount: Int) -> Item? {
        
        if roomsCount + 2 >= numberOfRooms {
            if !isHaveKey {
                isHaveKey = true
                isDark = false
                return .key
            }
            
            if !isHaveChest {
                isDark = false
                isHaveChest = true
                return .chest
            }
        }
        
        let rand = Int.random(in: 0...100)
        if rand > 70 {
            return .gold(rand)
        }
        
        if rand > 35 && rand < 50 {
            return .torch
        }
        
        if rand > 15 && rand < 35 && !isDark && !isHaveKey {
            isHaveKey = true
            return .key
        }
        
        if rand < 15  && !isDark && !isHaveChest {
            isHaveChest = true
            return .chest
        }
        
        return nil
    }
    
    //5% шанс что комната будет темная
    private func chanceOfDarkRoom() -> Bool {
        let rand = Int.random(in: 0...100)
        if rand <= 5 {
            return true
        } else {
            return false
        }
    }
    
    //Функцяи расчета размера нашей прямоугольной матрицы
    private func calculateMatrixSize(for number: Int) -> (rows: Int, cols: Int) {
        let rows = Int(Double(number).squareRoot()) // считаем кол-во рядов
        let cols = Int(ceil(Double(number) / Double(rows))) // считаем кол-во столбцов
        return (rows, cols)
    }
    
    //Метод для спавна игрока
    func spawnPlayer() -> Position {
        let allRoom = map.flatMap({ $0 })
        let visibleRoom = allRoom.filter({ $0.isDark != true && $0.item != .chest })
        
        guard let spawnPosition = visibleRoom.randomElement() else {
            return Position(x: 1, y: 1)
        }
        
        return spawnPosition.position
    }
    
    //Метод нахождения возможных вариантов прохода
    func availableDirection(position: Position) -> [Directions] {
        var directions = [Directions]()
        
        for direction in Directions.allCases {
            let nextPosition = position.move(to: direction)
            
            if isRoomExist(on: nextPosition) {
                directions.append(direction)
            }
        }
        
        return directions
    }
    
    
    //Вспомогательный метод, что бы проверять существует ли комната
    private func isRoomExist(on position: Position) -> Bool {
        let x = position.x - 1
        let y = position.y - 1
        
        guard x >= 0, y >= 0, x < map.count else { return false }
        guard y < map[x].count else { return false }
        
        return true
    }
    
    //Описание комнаты
    func describeRoom(for position: Position, _ player: Player) {
        let posText = "You are in the room [\(position.x), \(position.y)]. "
        let availableDirection = availableDirection(position: position)
        
        let doors = availableDirection.map({ $0.rawValue })
        let doorsText = "There are \(availableDirection.count) doors: \(doors). "
        
        let currentRoom = map[position.x - 1][position.y - 1]

        var item = ""
        var darkText = ""
        if currentRoom.item != nil && (!currentRoom.isDark || (currentRoom.isDark && player.inventory.contains(.torch))) {
            item = "\(currentRoom.item!)"
        } else if currentRoom.isDark && !player.inventory.contains(.torch){
            item = "... "
            darkText = "Can’t see anything in this dark place!"
        } else {
            item = "empty"
        }
            
        let itemText = "Items in the room: \(item)"
        print(posText + doorsText + itemText + darkText)
    }
}


extension Position {
    func move(to direction: Directions) -> Position {
        switch direction {
        case .east: return Position(x: x, y: y + 1)
        case .north: return Position(x: x - 1, y: y)
        case .south: return Position(x: x + 1, y: y)
        case .west: return Position(x: x, y: y - 1)
        }
    }
}
