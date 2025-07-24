//
//  NetworkError.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 23.07.2025.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case unauthorized
    case notFound
    case encodingError(Error)
    case decodingError(Error)
    case serverError(Int)
    case unknownError(Error)
    case invalidDataOrIdentifier
}
