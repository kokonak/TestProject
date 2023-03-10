//
//  HomeAPI.swift
//  TestProject
//
//  Created by kokonak on 2023/03/09.
//

import Foundation
import Moya

enum HomeAPI {

    case getHomeData
    case getGoodsList(lastId: Int)
}

extension HomeAPI: TargetType {

    var baseURL: URL { URL(string: "http://d2bab9i9pr8lds.cloudfront.net/api/home")! }

    var path: String {
        switch self {
            case .getHomeData: return ""
            case .getGoodsList: return "/goods"
        }
    }

    var method: Moya.Method {
        switch self {
            case .getHomeData: return .get
            case .getGoodsList: return .get
        }
    }

    var task: Moya.Task {
        switch self {
            case .getHomeData:
                return .requestPlain
            case .getGoodsList(let lastId):
                let params: [String: Any] = ["lastId": lastId]
                return .requestParameters(parameters: params, encoding: URLEncoding.queryString )
        }
    }

    var headers: [String : String]? { nil }
}
