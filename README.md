# SeaDog

*SeaDog* is a set of NSConstraint extension to make life with auto layout even more pleasant.

## Evaluating constraints

The main addition to NSConstraints is a new sibling to `activateConstraints`. It is called `evaluateConstraints` and it activates and deactivates constraints dynamically based on a new NSConstraint property – the `activationRule`.

Currently, there are five cases in `ConstraintActivationRule`:

- `manual`: The constraint is ignored by `evaluateConstraints`.
- `always` __(Default__): The constraint will be activated if it is not already active.
- `bothVisible`: Activates a constraint if all participating views are visible. Otherwise the constraint will be deactivated.
- `firstInvisible`: Activates the constraint if the first partipating view is invisible. Otherwise it will be deactivated.
- `delegate`: Delegates the decision to activate or deactivate a constraint to the delegate if it was passed into `evaluateConstraints`

## Extended anchor construction functions

Do you ever wished it was easier to define a constraint using the anchor API including priority and identifier, without assigning the constraint to a variable? `SeaDog` gives every anchor API a new sibling that does exacly that.

```swift
NSLayoutConstraint.activateConstraints([
    view.topAnchor.constraint(equalTo: otherView.topAnchor, priority: .defaultLow)
])
```

To see how this all works together, look at the example and read the comments.

## Complete example

```swift
import UIKit
import SeaDog

class ViewController: UIViewController {
    
    private lazy var redView = UIView()
    private lazy var blueView = UIView()

    // All relevant view constraints, defined including `priority` and `activationRule`!
    private lazy var viewConstraints = [
        redView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
        redView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, priority: .defaultLow),
        redView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
        redView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor),
        redView.heightAnchor.constraint(equalToConstant: 0, activationRule: .firstInvisible), // Gives the view an height when it is hidden, so there is a target frame to animate to.

        blueView.topAnchor.constraintEqualToSystemSpacingBelow(redView.bottomAnchor, multiplier: 1, activationRule: .bothVisible), // Links the blue view to the red view if both are visible,
        blueView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, priority: .defaultLow), // Fallback if other topAnchor is deactivated.
        blueView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
        blueView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
        blueView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor),
        blueView.heightAnchor.constraint(equalTo: redView.heightAnchor, activationRule: .bothVisible), // Same height when both views are visible
        blueView.heightAnchor.constraint(equalToConstant: 0, activationRule: .firstInvisible) // Gives the view an height when it is hidden, so there is a target frame to animate to.
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()

        // Schedule a call to `updateViewConstraints`.
        view.setNeedsUpdateConstraints()
    }

    private func addSubviews() {
        view.layoutMargins = UIEdgeInsetsMake(15, 15, 15, 15)

        redView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapGesture)))
        redView.backgroundColor = .red
        redView.layer.cornerRadius = 5
        redView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(redView)
        
        blueView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapGesture)))
        blueView.backgroundColor = .blue
        blueView.layer.cornerRadius = 5
        blueView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blueView)
    }

    // The constraints defined on top are activated or deactivated simply by
    // calling `NSLayoutConstraint.evaluateConstraints(viewConstraints)`.
    override func updateViewConstraints() {
        NSLayoutConstraint.evaluateConstraints(viewConstraints)
        super.updateViewConstraints()
    }
    
    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        UIView.animate(withDuration: 1/3) { [weak self] in
            guard let redView = self?.redView, let blueView = self?.blueView else { return }
            
            if gesture.view == blueView {
                if redView.alpha == 0 {
                    redView.alpha = 1
                } else {
                    blueView.alpha = 0
                }
            }
            
            if gesture.view == redView {
                if blueView.alpha == 0 {
                    blueView.alpha = 1
                } else {
                    redView.alpha = 0
                }
            }

            // Force an execution of `updateViewConstraints` inside
            // this animation block.
            self?.view.setNeedsUpdateConstraints()
            self?.view.layoutIfNeeded()
        }
    }
}
```