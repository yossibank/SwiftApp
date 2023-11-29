import SwiftUI
import UIKit

open class SwiftUIViewController<SwiftUIView: View>: UIViewController {
    private let contentView: SwiftUIView

    public init(contentView: SwiftUIView) {
        self.contentView = contentView
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLoad() {
        setView(contentView)
    }
}
