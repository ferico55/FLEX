//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport
import Render

var str = "Hello, playground"
var containerView = UIView()
containerView.backgroundColor = UIColor.red
containerView.frame = CGRect(x: 0, y: 0, width: 320, height: 528)

PlaygroundPage.current.liveView = containerView
PlaygroundPage.current.needsIndefiniteExecution = true

struct IntermediaryState: StateType {
    
}

class IntermediaryViewComponent: ComponentView<IntermediaryState> {
    override func construct(state: IntermediaryState?, size: CGSize) -> NodeType {
        let containerView = Node<UIScrollView>{ scrollView, layout, size in
            scrollView.backgroundColor = UIColor.green
            layout.width = 320
            layout.height = 528
            layout.justifyContent = .flexStart
        }
        
        let bannerView = Node<UIView> { view, layout, size in
            view.backgroundColor = UIColor.black
            layout.justifyContent = .center
            layout.alignItems = .flexStart
            layout.height = 150
        }
        
        let titleLabel = Node<UILabel> { label, layout, size in
            label.text = "Fashion Wanita"
            label.textColor = UIColor.white
            label.backgroundColor = UIColor.brown
        }
        
        let hotListView = Node<UIView> { view, layout, size in
            view.backgroundColor = UIColor.blue
            layout.height = 150
        }
        
        bannerView.add(child: titleLabel)
        
        return containerView.add(children: [bannerView, hotListView])
    }
}

let intermediaryView = IntermediaryViewComponent()
intermediaryView.state = IntermediaryState()
intermediaryView.render(in: containerView.bounds.size)
intermediaryView.render(in: containerView.bounds.size)

containerView.addSubview(intermediaryView)







