//
//  FavoriteGoodsManager.swift
//  TestProject
//
//  Created by kokonak on 2023/03/09.
//

import Foundation
import RxSwift
import RxRelay
import RealmSwift

#warning("code 정리 필요")
final class FavoriteGoodsManager {

    static let shared = FavoriteGoodsManager()
    private(set) var isLoadedDone: Bool = false
    private(set) lazy var favoriteGoodsList: Observable<[Goods]> = goodsListRelay.asObservable()
    private lazy var goodsListRelay = BehaviorRelay<[Goods]>(value: [])
    private let pageSize: Int = 5
    private let realm = try! Realm()

    init() {
        loadData()
    }

    func loadData() {
        isLoadedDone = false
        let goodsList = getGoodsList()
        goodsListRelay.accept(goodsList)
    }

    func loadNext() {
        guard !isLoadedDone else { return }
        guard let last = goodsListRelay.value.last else { return }

        let nextList = getGoodsList(lastId: last.id)

        guard nextList.isNotEmpty else { return }
        goodsListRelay.accept(goodsListRelay.value + nextList)
    }

    func isFavoriteGoods(_ goodsId: Int) -> Bool {
        realm.object(ofType: GoodsRealmObject.self, forPrimaryKey: goodsId) != nil
    }

    func addGoods(_ goods: Goods) {
        var goodsList = goodsListRelay.value
        goodsList.insert(goods, at: 0)
        goodsListRelay.accept(goodsList)

        let object = GoodsRealmObject.init(goods: goods)
        let realm = try! Realm()
        try! realm.write {
            realm.add(object)
        }
    }

    func removeGoods(_ goods: Goods) {
        var goodsList = goodsListRelay.value
        goodsList.removeAll(where: { $0.id == goods.id })
        goodsListRelay.accept(goodsList)

        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.objects(GoodsRealmObject.self).where { $0.id == goods.id })
        }
    }
}

extension FavoriteGoodsManager {

    private func getGoodsList(lastId: Int? = nil) -> [Goods] {
        let objects = realm.objects(GoodsRealmObject.self).sorted(by: \.createdAt, ascending: false)

        let pageObject: [GoodsRealmObject]
        if let lastId = lastId {
            if let index = objects.firstIndex(where: { $0.id == lastId }) {
                let nextIndex = index + 1

                if nextIndex >= objects.count {
                    // lastId가 마지막 object였음, 즉 다음 쿼리 아이템 없음
                    pageObject = []
                } else {
                    // next item은 있을때
                    if nextIndex + pageSize < objects.count {
                        // page 개수만큼 가져올수 있을때
                        pageObject = Array(objects[nextIndex..<nextIndex+pageSize])
                    } else {
                        // pageSize보다 가져올게 적을때, 마지막 페이지
                        pageObject = Array(objects[nextIndex...])
                    }
                }
            } else {
                // lastId에 해당하는 object가 없을때
                pageObject = [] //
            }
        } else {
            // lastId가 없을 경우
            if objects.count > pageSize {
                pageObject = Array(objects[..<pageSize])
            } else {
                pageObject = Array(objects[0...])
            }
        }

        isLoadedDone = pageObject.isEmpty || pageObject.count < pageSize
        return pageObject.map { $0.asGoods() }
    }
}
