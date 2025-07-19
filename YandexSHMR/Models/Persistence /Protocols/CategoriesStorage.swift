//
//  CategoriesStorage.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 19.07.2025.
//

import Foundation

protocol CategoriesStorage {
    func saveCategories(_ categories: [Category]) async throws
    func getCategories() async throws -> [Category]
}
