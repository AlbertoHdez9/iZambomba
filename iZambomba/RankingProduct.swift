//
//  RankingProduct.swift
//  
//
//  Created by SingularNet on 28/1/19.
//

import Foundation

public struct RankingProduct {
    
    public static let SwiftShopping = "com.singularfactory.izambomba.rankingaccess"
    
    private static let productIdentifier: Set<ProductIdentifier> = [SwiftShopping]
    
    public static let store = IAPHelper(productId: RankingProduct.productIdentifier)
}

func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
    return productIdentifier.components(separatedBy: ".").last
}
