//
//  ArticlesView.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 19.06.2025.
//

import SwiftUI

struct ArticlesView: View {
    @State private var loadingState = LoadingState.loading
    @State private var categories: [Category] = []
    @State private var searchText = ""
    
    var searchedCategories: [Category] {
        guard !searchText.isEmpty else {
            return categories
        }
        
        return categories.filter {
            $0.name.fuzzySearch(stringToSearch: searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section("Статьи") {
                    ForEach(searchedCategories) { category in
                        HStack {
                            Text("\(category.emoji)")
                                .font(.system(size: 14.5))
                                .padding(4)
                                .background(.transactionIconBackground)
                                .clipShape(.circle)
                                .padding(.trailing, 16)
                            
                            Text(category.name)
                                .font(.system(size: 17))
                        }
                    }
                }
            }
            .navigationTitle("Мои статьи")
            .task {
                await fetchCategories()
            }
            .overlay {
                if loadingState == .loading {
                    ProgressView()
                } else if loadingState == .error {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 150))
                        .foregroundStyle(.red)
                        .padding(.bottom, 60)
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search")
    }
    
    func fetchCategories() async {
        loadingState = .loading
        do {
            categories = try await CategoriesService().categories()
            loadingState = .loaded
        } catch {
            print("Error loading categories: \(error.localizedDescription)")
            loadingState = .error
        }
    }
    
    enum LoadingState {
        case loading
        case loaded
        case error
    }
}

#Preview {
    ArticlesView()
}
