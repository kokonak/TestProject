//
//  ViewModel.swift
//  TestProject
//
//  Created by kokonak on 2023/03/07.
//

import Foundation
import RxSwift

protocol ViewModel {

    associatedtype Dependency
    associatedtype Input
    associatedtype Output

    var dependency: Dependency { get }
    var input: Input { get }
    var output: Output { get }
    var disposeBag: DisposeBag { get }

    func transform()
}
