//
//  fetchQuotes.swift
//  InspirationalQuotes
//
//  Created by Danielle Naa Okailey Quaye on 11/12/23.
//

import Foundation

class fetchQuotes {
    static func fetchRandomQuote(completion: @escaping (Result<Quote, Error>) -> Void) {
        let endpoint = "https://api.quotable.io/random"
        
        guard let url = URL(string: endpoint) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "Invalid Data", code: 0, userInfo: nil)))
                return
            }

            do {
                let decoder = JSONDecoder()
                let quote = try decoder.decode(Quote.self, from: data)
                completion(.success(quote))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
