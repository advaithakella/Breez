import UIKit

class LaunchScreenViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLaunchScreen()
    }
    
    private func setupLaunchScreen() {
        // Blue background (7DC7FF)
        view.backgroundColor = UIColor(red: 0.49, green: 0.78, blue: 1.0, alpha: 1.0)
        
        // Find the label from storyboard or create one
        let titleLabel: UILabel
        if let existingLabel = findLabel(in: view) {
            titleLabel = existingLabel
        } else {
            titleLabel = UILabel()
            titleLabel.text = "BREEZ"
            titleLabel.textAlignment = .center
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(titleLabel)
            
            // Set up constraints
            NSLayoutConstraint.activate([
                titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        }
        
        // Set font and color
        titleLabel.font = UIFont.frijole(size: 80)
        titleLabel.textColor = .white
        titleLabel.text = "BREEZ"
    }
    
    private func findLabel(in view: UIView) -> UILabel? {
        for subview in view.subviews {
            if let label = subview as? UILabel {
                return label
            }
            if let found = findLabel(in: subview) {
                return found
            }
        }
        return nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // No gradient to update
    }
}
