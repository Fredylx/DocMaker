import UIKit

extension UIApplication {
    static func dm_topViewController(
        base: UIViewController? = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }?
            .keyWindow?
            .rootViewController
    ) -> UIViewController? {
        if let navigation = base as? UINavigationController {
            return dm_topViewController(base: navigation.visibleViewController)
        }

        if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return dm_topViewController(base: selected)
        }

        if let presented = base?.presentedViewController {
            return dm_topViewController(base: presented)
        }

        return base
    }
}

private extension UIWindowScene {
    var keyWindow: UIWindow? {
        windows.first(where: { $0.isKeyWindow })
    }
}
