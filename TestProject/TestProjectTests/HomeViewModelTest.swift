//
//  HomeViewModelTest.swift
//  TestProjectTests
//
//  Created by kokonak on 2023/03/10.
//

import XCTest
@testable import TestProject
import RxSwift
import RxTest
import Moya
import RealmSwift

final class HomeViewModelTest: XCTestCase {

    override func setUp() {
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
    }

    func testInputLoadData() throws {
        let provider = MoyaProvider<HomeAPI>(endpointClosure: { target in
            Endpoint(
                url: URL(target: target).absoluteString,
                sampleResponseClosure: {
                    switch target {
                        case .getHomeData:
                            return .networkResponse(200, Self.mock)
                        case .getGoodsList:
                            return .networkResponse(200, Data())
                    }
                },
                method: target.method,
                task: target.task,
                httpHeaderFields: target.headers
            )
        }, stubClosure: MoyaProvider.immediatelyStub)

        let viewModel = HomeViewModel(.init(api: provider))

        let scheduler = TestScheduler(initialClock: 0)
        let disposeBag = DisposeBag()

        let triggerLoadData = scheduler.createHotObservable([.next(1, ())])
        triggerLoadData
            .bind(to: viewModel.input.loadData)
            .disposed(by: disposeBag)

        let sectionModelsObserver = scheduler.createObserver([HomeSectionModel].self)
        viewModel.output.sectionModels
            .bind(to: sectionModelsObserver)
            .disposed(by: disposeBag)

        let stopRefreshingObserver = scheduler.createObserver(Void.self)
        viewModel.output.stopRefreshing
            .bind(to: stopRefreshingObserver)
            .disposed(by: disposeBag)

        scheduler.start()

        XCTAssertEqual(sectionModelsObserver.events.count, 1)
        guard let section = sectionModelsObserver.events.first?.value.element?.first else {
            return XCTAssert(false)
        }
        XCTAssertEqual(
            section.bannerViewModel.dependency.banners,
            [Self.convert(object: Self.banner(id: 0), type: Banner.self)!]
        )
        XCTAssertEqual(
            section.items.map { $0.dependency.goods },
            [Self.convert(object: Self.goods(id: 0), type: Goods.self)!]
        )

        XCTAssertEqual(stopRefreshingObserver.events.count, 1)
    }

    func testInputLoadMore() throws {
        let provider = MoyaProvider<HomeAPI>(endpointClosure: { target in
            Endpoint(
                url: URL(target: target).absoluteString,
                sampleResponseClosure: {
                    switch target {
                        case .getHomeData:
                            return .networkResponse(200, Self.mock)
                        case .getGoodsList(let lastId):
                            let data: Data
                            switch lastId {
                                case 0:     data = Self.convertToData(["goods": [Self.goods(id: 1)]])
                                case 1:     data = Self.convertToData(["goods": [Self.goods(id: 2)]])
                                case 2:     data = Self.convertToData(["goods": []])
                                default:    data = Data()
                            }
                            return .networkResponse(200, data)
                    }
                },
                method: target.method,
                task: target.task,
                httpHeaderFields: target.headers
            )
        }, stubClosure: MoyaProvider.immediatelyStub)

        let viewModel = HomeViewModel(.init(api: provider))

        let scheduler = TestScheduler(initialClock: 0)
        let disposeBag = DisposeBag()

        let triggerLoadData = scheduler.createHotObservable([.next(1, ())])
        triggerLoadData
            .bind(to: viewModel.input.loadData)
            .disposed(by: disposeBag)

        let triggerLoadMore = scheduler.createHotObservable([
            .next(2, ()),
            .next(3, ()),
            .next(4, ()),
            .next(5, ()),
        ])
        triggerLoadMore
            .bind(to: viewModel.input.loadMore)
            .disposed(by: disposeBag)

        let sectionModelsObserver = scheduler.createObserver([HomeSectionModel].self)
        viewModel.output.sectionModels
            .bind(to: sectionModelsObserver)
            .disposed(by: disposeBag)

        scheduler.start()

        // sectionModels event는 loadData에서 한번 발생.
        // triggerLoadMore 이벤트의 발행수는 4개이지만 3, 4번째에선 빈 배열이 오므로 sectionModels event 발생하지 않음.
        XCTAssertEqual(sectionModelsObserver.events.count, 3)
        sectionModelsObserver.events.map { $0.value.element?.first }.enumerated().forEach { index, section in
            guard let section = section else { return XCTAssert(false, "SectionModel is nil") }

            switch index {
                case 0:
                    let expect: [Goods] = [
                        Self.convert(object: Self.goods(id: 0), type: Goods.self)!,
                    ]
                    XCTAssertEqual(section.items.map { $0.dependency.goods }, expect)
                case 1:
                    let expect: [Goods] = [
                        Self.convert(object: Self.goods(id: 0), type: Goods.self)!,
                        Self.convert(object: Self.goods(id: 1), type: Goods.self)!,
                    ]
                    XCTAssertEqual(section.items.map { $0.dependency.goods }, expect)
                case 2:
                    let expect: [Goods] = [
                        Self.convert(object: Self.goods(id: 0), type: Goods.self)!,
                        Self.convert(object: Self.goods(id: 1), type: Goods.self)!,
                        Self.convert(object: Self.goods(id: 2), type: Goods.self)!
                    ]
                    XCTAssertEqual(section.items.map { $0.dependency.goods }, expect)
                default:
                    XCTAssert(false, "Invalid event")
            }
        }
    }
}

extension HomeViewModelTest {

    static var mock: Data {
        try! JSONSerialization.data(withJSONObject: [
            "banners": [
                banner(id: 0)
            ],
            "goods": [
                goods(id: 0)
            ]
        ])
    }

    static func convert<T: Decodable>(object: [String: Any], type: T.Type) -> T? {
        guard let data = try? JSONSerialization.data(withJSONObject: object),
              let model = try? JSONDecoder().decode(T.self, from: data)
        else {
            return nil
        }
        return model
    }

    static func banner(id: Int) -> [String: Any] {
        [
            "id": id,
            "image": ""
        ]
    }

    static func goods(id: Int) -> [String: Any] {
        [
            "id": id,
            "name": "goods-\(id)",
            "image": "image",
            "actual_price": 1000,
            "price": 1000,
            "is_new": false,
            "sell_count": 0
        ]
    }

    static func convertToData(_ value: Any) -> Data {
        try! JSONSerialization.data(withJSONObject: value)
    }
}
