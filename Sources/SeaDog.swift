//
//  SeaDog.swift
//  bruns.me
//
//  Created by Karsten Bruns on 12.04.18.
//  Copyright © 2018 bruns.me. All rights reserved.
//

import UIKit


/// Describes the behaviour of a constraint when it is evaluated by `evaluateConstraints`.
///
/// - manual: The constraint is ignored by `evaluateConstraints`.
/// - always: The constraint will be activated if it is not already active.
/// - bothVisible: Activates a constraint if all participating views are visible. Otherwise the constraint will be deactivated.
/// - firstInvisible: Activates the constraint if the first partipating view is invisible. Otherwise it will be deactivated.
/// - delegate: Delegates the decision to activate or deactivate a constraint to the delegate if it was passed into `evaluateConstraints`
public enum ConstraintActivationRule {
    case manual
    case always
    case bothVisible
    case firstInvisible
    case delegate
}


extension NSLayoutConstraint {
    
    private struct AssociatedKeys {
        static var activationRule = "activationRule"
    }
    
    /// The rule describing the behaviour of a constraint when it is evaluated by `evaluateConstraints`.
    open var activationRule: ConstraintActivationRule {
        get {
            return associatedValue(forKey: &AssociatedKeys.activationRule) ?? .always
        }
        set {
            setAssociatedValue(newValue, forKey: &AssociatedKeys.activationRule)
        }
    }
    
    /// Activates and deactivates constraints based on the constraints state of the
    /// `activationRule` and the state of the participating views.
    ///
    /// - Parameters:
    ///   - constraints: A list of constraints that should be automatically activated or deactivated.
    ///   - delegate: An optional reference to a class, that decides if a constraint starting with the `delegate`
    ///               activation rule should be activated or not.
    open static func evaluateConstraints(_ constraints: [NSLayoutConstraint], delegate: LayoutConstraintDelegate? = nil) {
        var constraintsToActivate = [NSLayoutConstraint]()
        var constraintsToDeactivate = [NSLayoutConstraint]()
        
        for constraint in constraints {
            // Handle constraint for invisible views
            let viewIsHidden = (constraint.firstItem as? UIView)?.isInvisible == true
            if constraint.activationRule == .firstInvisible {
                if viewIsHidden && !constraint.isActive {
                    constraintsToActivate.append(constraint)
                } else if !viewIsHidden && constraint.isActive {
                    constraintsToDeactivate.append(constraint)
                }
                continue
            }
            
            // Handle visibility dependent constraints
            if constraint.activationRule == .bothVisible {
                // `true` if one participating view is hidden
                let deactivateConstraint = [constraint.firstItem, constraint.secondItem]
                    .compactMap({ $0 as? UIView })
                    .contains(where: { $0.isInvisible })
                
                if deactivateConstraint && constraint.isActive {
                    constraintsToDeactivate.append(constraint)
                } else if !deactivateConstraint && !constraint.isActive {
                    constraintsToActivate.append(constraint)
                }
                continue
            }
            
            // Handle delegate managed constraints
            if constraint.activationRule == .delegate, let delegate = delegate {
                let shouldBeActive = delegate.shouldActivateConstraint(constraint)
                if shouldBeActive && !constraint.isActive {
                    constraintsToActivate.append(constraint)
                } else if !shouldBeActive && constraint.isActive {
                    constraintsToDeactivate.append(constraint)
                }
                continue
            }
            
            // Handle always active constraints
            if constraint.activationRule == .always, !constraint.isActive {
                constraintsToActivate.append(constraint)
            }
        }
        
        NSLayoutConstraint.activate(constraintsToActivate)
        NSLayoutConstraint.deactivate(constraintsToDeactivate)
    }
}


/// Classes conforming to this protocol can decide if a constraint should be activated or not
/// when evaluated in NSConstraint's `evaluateConstraints`.
public protocol LayoutConstraintDelegate {
    /// Called to ask the receiver if a constraint should be activated or deactivated.
    ///
    /// - Parameter constraint: The constraint in question.
    /// - Returns: Return to `true` to activate the constraint if needed and return `false` to deactivate the constraint if needed.
    func shouldActivateConstraint(_ constraint: NSLayoutConstraint) -> Bool
}


@available(iOSApplicationExtension 9.0, *)
extension NSLayoutXAxisAnchor {
    func constraint(equalTo anchor: NSLayoutXAxisAnchor, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(equalTo: anchor)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    func constraint(greaterThanOrEqualTo anchor: NSLayoutXAxisAnchor, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(greaterThanOrEqualTo: anchor)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    func constraint(lessThanOrEqualTo anchor: NSLayoutXAxisAnchor, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(lessThanOrEqualTo: anchor)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    func constraint(equalTo anchor: NSLayoutXAxisAnchor, constant c: CGFloat, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(equalTo: anchor, constant: c)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    func constraint(greaterThanOrEqualTo anchor: NSLayoutXAxisAnchor, constant c: CGFloat, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(greaterThanOrEqualTo: anchor, constant: c)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    func constraint(lessThanOrEqualTo anchor: NSLayoutXAxisAnchor, constant c: CGFloat, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(lessThanOrEqualTo: anchor, constant: c)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    @available(iOS 11.0, *)
    open func constraintEqualToSystemSpacingAfter(_ anchor: NSLayoutXAxisAnchor, multiplier: CGFloat, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraintEqualToSystemSpacingAfter(anchor, multiplier: multiplier)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    @available(iOS 11.0, *)
    open func constraintGreaterThanOrEqualToSystemSpacingAfter(_ anchor: NSLayoutXAxisAnchor, multiplier: CGFloat, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraintGreaterThanOrEqualToSystemSpacingAfter(anchor, multiplier: multiplier)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    @available(iOS 11.0, *)
    open func constraintLessThanOrEqualToSystemSpacingAfter(_ anchor: NSLayoutXAxisAnchor, multiplier: CGFloat, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraintLessThanOrEqualToSystemSpacingAfter(anchor, multiplier: multiplier)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
}


@available(iOSApplicationExtension 9.0, *)
extension NSLayoutYAxisAnchor {
    func constraint(equalTo anchor: NSLayoutYAxisAnchor, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(equalTo: anchor)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    func constraint(greaterThanOrEqualTo anchor: NSLayoutYAxisAnchor, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(greaterThanOrEqualTo: anchor)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    func constraint(lessThanOrEqualTo anchor: NSLayoutYAxisAnchor, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(lessThanOrEqualTo: anchor)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    func constraint(equalTo anchor: NSLayoutYAxisAnchor, constant c: CGFloat, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(equalTo: anchor, constant: c)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    func constraint(greaterThanOrEqualTo anchor: NSLayoutYAxisAnchor, constant c: CGFloat, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(greaterThanOrEqualTo: anchor, constant: c)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    func constraint(lessThanOrEqualTo anchor: NSLayoutYAxisAnchor, constant c: CGFloat, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(lessThanOrEqualTo: anchor, constant: c)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    @available(iOS 11.0, *)
    open func constraintEqualToSystemSpacingBelow(_ anchor: NSLayoutYAxisAnchor, multiplier: CGFloat, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraintEqualToSystemSpacingBelow(anchor, multiplier: multiplier)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    @available(iOS 11.0, *)
    open func constraintGreaterThanOrEqualToSystemSpacingBelow(_ anchor: NSLayoutYAxisAnchor, multiplier: CGFloat, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraintGreaterThanOrEqualToSystemSpacingBelow(anchor, multiplier: multiplier)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    @available(iOS 11.0, *)
    open func constraintLessThanOrEqualToSystemSpacingBelow(_ anchor: NSLayoutYAxisAnchor, multiplier: CGFloat, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraintLessThanOrEqualToSystemSpacingBelow(anchor, multiplier: multiplier)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
}


@available(iOSApplicationExtension 9.0, *)
extension NSLayoutDimension {
    open func constraint(equalTo anchor: NSLayoutDimension, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(equalTo: anchor)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    open func constraint(greaterThanOrEqualTo anchor: NSLayoutDimension, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(greaterThanOrEqualTo: anchor)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    open func constraint(lessThanOrEqualTo anchor: NSLayoutDimension, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(lessThanOrEqualTo: anchor)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    open func constraint(equalTo anchor: NSLayoutDimension, constant c: CGFloat, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(equalTo: anchor, constant: c)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    open func constraint(greaterThanOrEqualTo anchor: NSLayoutDimension, constant c: CGFloat, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(greaterThanOrEqualTo: anchor, constant: c)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    open func constraint(lessThanOrEqualTo anchor: NSLayoutDimension, constant c: CGFloat, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(lessThanOrEqualTo: anchor, constant: c)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    open func constraint(equalToConstant c: CGFloat, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(equalToConstant: c)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    open func constraint(greaterThanOrEqualToConstant c: CGFloat, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(greaterThanOrEqualToConstant: c)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    open func constraint(lessThanOrEqualToConstant c: CGFloat, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(lessThanOrEqualToConstant: c)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    open func constraint(equalTo anchor: NSLayoutDimension, multiplier m: CGFloat, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(equalTo: anchor, multiplier: m)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    open func constraint(greaterThanOrEqualTo anchor: NSLayoutDimension, multiplier m: CGFloat, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(greaterThanOrEqualTo: anchor, multiplier: m)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    open func constraint(lessThanOrEqualTo anchor: NSLayoutDimension, multiplier m: CGFloat, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(lessThanOrEqualTo: anchor, multiplier: m)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    open func constraint(equalTo anchor: NSLayoutDimension, multiplier m: CGFloat, constant c: CGFloat, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(equalTo: anchor, multiplier: m)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    open func constraint(greaterThanOrEqualTo anchor: NSLayoutDimension, multiplier m: CGFloat, constant c: CGFloat, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(greaterThanOrEqualTo: anchor, multiplier: m)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
    
    open func constraint(lessThanOrEqualTo anchor: NSLayoutDimension, multiplier m: CGFloat, constant c: CGFloat, identifier: String? = nil, priority: UILayoutPriority = .required, activationRule: ConstraintActivationRule = .always) -> NSLayoutConstraint {
        let newConstraint = constraint(lessThanOrEqualTo: anchor, multiplier: m, constant: c)
        newConstraint.identifier = identifier
        newConstraint.priority = priority
        newConstraint.activationRule = activationRule
        return newConstraint
    }
}


// MARK: Helper

private extension UIView {
    var isInvisible: Bool {
        // TODO: Check Ancestors
        return isHidden || alpha <= 0
    }
}
