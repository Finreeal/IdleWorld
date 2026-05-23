import SwiftUI
import WidgetKit

@main
struct IdleWorldWidgetBundle: WidgetBundle {
    var body: some Widget {
        IdleWorldWidget()
        DeepFocusLiveActivity()
    }
}
