//
//  ResponseType.swift
//  TestProject
//
//  Created by kokonak on 2023/03/10.
//

enum ResponseType<T> {

    case success(T)
    case failure(Error)

    @discardableResult
    func getSuccess() -> T? {
        switch self {
            case .success(let model):   return model
            case .failure:              return nil
        }
    }

    @discardableResult
    func getFailure() -> Error? {
        switch self {
            case .success:              return nil
            case .failure(let error):   return error
        }
    }
}
