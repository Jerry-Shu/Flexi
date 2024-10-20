//
//  EvaluationData.swift
//  Flexi_iOS
//
//  Created by Jiarui Shu on 10/20/24.
//

import Foundation

struct EvaluationData: Decodable {
    let audio: String
    let overallEvaluation: [String]
    let potentialImprovement: [Improvement]
    let rating: Int

    struct Improvement: Decodable {
        let problem: String
        let improvement: String
    }

    private enum CodingKeys: String, CodingKey {
        case audio
        case overallEvaluation = "overall_evaluation"
        case potentialImprovement = "potential_improvement"
        case rating
    }
}
