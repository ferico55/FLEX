//
//  GlobalViewComponent.swift
//  Demo
//
//  Created by Setiady Wiguna on 4/20/17.
//  Copyright © 2017 Alex Usbergo. All rights reserved.
//

import UIKit
import Render

struct GlobalRenderComponent {

    static func horizontalLine(identifier: String, marginLeft: CGFloat?) -> NodeType {
        return Node<UIView>(identifier: identifier) { view, layout, _ in
            layout.height = 1
            view.backgroundColor = .white
        }.add(children: [
            Node<UIView>() { view, layout, _ in
                layout.height = 1
                layout.marginLeft = marginLeft ?? 0
                view.backgroundColor = .tpLine()
            }
        ])
    }

    static func verticalLine(identifier: String) -> NodeType {
        return Node<UIView>(identifier: identifier) { view, layout, size in
            layout.width = 1
            layout.height = size.height
            view.backgroundColor = .tpLine()
        }
    }
}
