//
//  BindableController.swift
//  boxotop
//
//  Created by Baldoph on 31/10/2018.
//  Copyright © 2018 Baldoph Pourprix. All rights reserved.
//

import UIKit
import TSAO
import RxSwift

private let viewModelMap = AssocMap<ViewModel>()
private let disposeBagMap = AssocMap<DisposeBag>()

protocol Bindable {
    associatedtype Model: ViewModel
    func bind(viewModel: Model)
}

extension Bindable where Self: UIViewController {
    var viewModel: Model! {
        return viewModelMap[self] as? Self.Model
    }

    var disposeBag: DisposeBag {
        var bag: DisposeBag! = disposeBagMap[self]
        if bag == nil {
            bag = DisposeBag()
            disposeBagMap[self] = bag
        }
        return bag
    }

    func set(viewModel: Model) {
        viewModelMap[self] = viewModel
        self.rx.methodInvoked(#selector(viewDidLoad)).take(1).bind { [unowned self] _ in
            self.bind(viewModel: viewModel)
        }.disposed(by: disposeBag)
    }
}
