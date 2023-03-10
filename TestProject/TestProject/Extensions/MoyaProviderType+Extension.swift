//
//  MoyaProviderType+Extension.swift
//  TestProject
//
//  Created by kokonak on 2023/03/10.
//

import Foundation
import RxSwift
import Moya

extension Reactive where Base: MoyaProviderType {

    func request<T: Decodable>(
        _ token: Base.Target,
        callbackQueue: DispatchQueue? = nil,
        of type: T.Type
    ) -> Single<ResponseType<T>> {
        Single.create { [weak base] single in
            let cancellableToken = base?.request(token, callbackQueue: callbackQueue, progress: nil) { result in
                switch result {
                    case let .success(response):
                        if let model = try? response.map(T.self) {
                            single(.success(.success(model)))
                        } else {
                            single(.success(.failure(NSError(domain: "failed to map model: \(T.self)", code: 0))))
                        }
                    case let .failure(error):
                        single(.success(.failure(error)))
                }
            }

            return Disposables.create {
                cancellableToken?.cancel()
            }
        }
    }
}
