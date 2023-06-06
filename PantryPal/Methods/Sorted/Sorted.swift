//
//  Sorted.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/6/6.
//

import Foundation
func chooseSort(_ action: Int, _ dataArray: [PresentIngredientsData]) -> [PresentIngredientsData] {
    if action == 0 {
        return sortByName(dataArray)
    }
    if action == 1 {
        return sortByLeftTime(dataArray)
    }
    return dataArray
}

func sortByName(_ dataArray: [PresentIngredientsData]) -> [PresentIngredientsData] {
    let sortedData = dataArray.sorted { (ingredient1, ingredient2) -> Bool in
        return ingredient1.name < ingredient2.name
    }
    return sortedData
}

func sortByLeftTime(_ dataArray: [PresentIngredientsData]) -> [PresentIngredientsData] {
    let sortedData = dataArray.sorted { (ingredient1, ingredient2) -> Bool in
        return ingredient1.expiration < ingredient2.expiration
    }
    return sortedData
}
