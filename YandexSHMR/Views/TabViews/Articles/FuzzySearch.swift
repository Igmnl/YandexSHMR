//
//  FuzzySearch.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 04.07.2025.
//

import Foundation

extension String {
    func fuzzySearch(stringToSearch: String) -> Bool {
        guard self.count != 0 || stringToSearch.count != 0 else
        { return false }
        
        guard self.count >= stringToSearch.count else { return false }
        
        let tempOriginalString = self.lowercased()
        let tempStringToSearch = stringToSearch.lowercased()
        
        var searchIndex : Int = 0
        var searchCount : Int = 0
        
        for origChar in tempOriginalString {
            for (indexIn, tempChar) in tempStringToSearch.enumerated() {
                if indexIn == searchIndex {
                    if origChar == tempChar {
                        searchIndex += 1
                        if searchIndex == tempStringToSearch.count {
                            searchCount += 1
                            searchIndex = 0
                        } else {
                            break
                        }
                    } else {
                        break
                    }
                }
            }
        }
        return searchCount > 0
    }
}
