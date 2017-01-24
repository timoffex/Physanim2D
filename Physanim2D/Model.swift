//
//  Model.swift
//  Physanim2D
//
//  Created by Tima Peshin on 1/21/17.
//  Copyright © 2017 timoffex. All rights reserved.
//

import Foundation


class Model {
    
    /// Maps every joint in [1, n) to a parent in [0, n)
    /// 0 is the root joint and has no parent (-1)
    var jointParents: [Int]
    
    
    /// Maps every joint in [1, n) to an angle.
    /// Since 0 is root, its angle is meaningless
    var jointAngles: [Angle]
    
    
    /// Maps every joint in [1, n) to a distance.
    /// Since 0 is root, its distance is meaningless
    var jointDistances: [Double]
    
    
    /// Position of the root joint.
    var rootPosition: Vec2
    
    
    /// Reference direction of the root joint.
    var rootReferenceDir: Vec2
    
    
    /// Number of joints in this model.
    var numJoints: Int {
        get {
            return jointParents.count
        }
    }
    
    
    
    /// Instantiates a model with 1 joint
    init(rootPos: Vec2, rootDir: Vec2) {
        jointParents = [-1]
        jointAngles = [Angle(0)]
        jointDistances = [0]
        
        rootPosition = rootPos
        rootReferenceDir = rootDir
    }
    
    
    
    func addJoint(parent: Int, distance: Double, angle: Angle) {
        jointParents.append(parent)
        jointDistances.append(distance)
        jointAngles.append(angle)
    }
    
    
    
    
    /// Adjusts the model's angles and root position to move certain joints to certain target positions
    func moveToPoseWith(targetPositions targets: [Vec2], forIndices indices: [Int], maxIterations: Int? = nil) {
        
        let tolerance = 0.05
        var stepSize = 0.1
        
        var gradientMagnitude: Double
        
        var finalCost: Double = Double.infinity
        
        // Perform gradient descent over rootPosition and jointAngles to minimize cost
        var iteration = 1
        repeat {
            
            // 1) Compute positions.
            let positions = getPositions()
            
            // 2) Compute cost and gradient.
            let (cost, gradRoot, gradAngle) = computeCostAndGradient(forTargetPositions: targets, withIndices: indices, andPositions: positions)
            
            
            // 3) If new cost is greater than previous cost, reduce step size.
            if cost > finalCost {
                stepSize *= 0.5
            }
            
            
            // 4) Adjust parameters in the direction opposite the gradient.
            rootPosition = rootPosition - stepSize * gradRoot
            jointAngles = (0..<numJoints).map { (jointIdx) in
                if jointIdx == 0 {
                    return Angle(0.0)
                } else {
                    return jointAngles[jointIdx] - stepSize * gradAngle[jointIdx-1]
                }
            }
            
            // 5) Compute gradientMagnitude to check for loop exit condition.
            gradientMagnitude = sqrt(gradRoot.sqrMagnitude + gradAngle.reduce(0, { $0 + $1*$1 }))
            
            
            // 6) Remember our cost during this iteration.
            finalCost = cost
            
            
            // Debugging information
//            print("Iteration: \(iteration), cost: \(cost), gradient magnitude: \(gradientMagnitude)")
            iteration += 1
            
        } while gradientMagnitude > tolerance && (maxIterations != nil ? true : iteration <= maxIterations!)
        
        
        // Debugging information
//        print("Cost: \(finalCost), gradient magnitude: \(gradientMagnitude)")
        
    }
    
    
    
    /// Computes the cost and the gradient of the model.
    /// Returns (cost, gradient wrt root pos, [gradient wrt angle 1, gradient wrt angle 2, ..., gradient wrt angle numJoints-1])
    func computeCostAndGradient(forTargetPositions targets: [Vec2], withIndices indices: [Int], andPositions positions: [Vec2]) -> (Double, Vec2, [Double]) {
        
        var costSum: Double = 0
        var rootGradSum: Vec2 = Vec2(x: 0, y: 0)
        var angleGradSums: [Double] = [Double](repeating: 0, count: numJoints-1)
        
        
        var targetIndex = 0
        
        for index in indices {
            let errorVec = positions[index] - targets[targetIndex]
            
            costSum += errorVec.sqrMagnitude
            rootGradSum = rootGradSum + 2 * errorVec
            
            for angleIdx in 0..<numJoints-1 {
                let angleJointIdx = angleIdx + 1
                
                if isJointDescendantOf(parent: angleJointIdx, child: index) {
                    let dif = positions[index] - positions[jointParents[angleJointIdx]]
                    
                    let deriv = dif.rotatedCCW(theta: Angle(M_PI/2))
                    
                    angleGradSums[angleIdx] += 2 * errorVec • deriv
                }
            }
            
            targetIndex = targetIndex + 1
        }
        
        
        return (costSum, rootGradSum, angleGradSums)
    }
    
    
    
    /// Computes the derivative of computeCost() with respect to the given joint
    func computeDCostDJointAngle(forJoint joint: Int, forTargetPositions targets: [Vec2], withIndices indices: [Int], andPositions positions: [Vec2]) -> Double {
        var sum: Double = 0
        
        let jointParent = jointParents[joint]
    
        var targetIndex = 0
        for index in indices {
            
            // Joint will only contribute to derivative if it is affected by the spinning joint.
            if isJointDescendantOf(parent: joint, child: index) {
                
                let dif = positions[index] - positions[jointParent]
                
                let deriv = dif.rotatedCCW(theta: Angle(M_PI/2))
                
                sum += 2 * (positions[index] - targets[targetIndex]) • deriv
            }
            
            targetIndex += 1
        }
        
        return sum
    }
    
    
    /// Computes the derivative of computeCost() with respect to rootPosition
    func computeDCostDRoot(forTargetPositions targets: [Vec2], withIndices indices: [Int], andPositions positions: [Vec2]) -> Vec2 {
        var sum: Vec2 = Vec2(x: 0, y: 0)
        
        var targetIndex = 0
        for index in indices {
            sum = sum + 2 * (positions[index] - targets[targetIndex])
            
            targetIndex += 1
        }
        
        return sum
    }
    
    
    /// Computes the sum of square distances between the given target positions
    /// and their corresponding joint positions.
    func computeCost(forTargetPositions targets: [Vec2], withIndices indices: [Int], andPositions positions: [Vec2]) -> Double {
        var sum: Double = 0
        
        var targetIndex = 0
        for index in indices {
            sum += (positions[index] - targets[targetIndex]).sqrMagnitude
            
            targetIndex += 1
        }
        
        return sum
    }
    
    
    /// Returns true if child is a descendant of parent, false otherwise.
    func isJointDescendantOf(parent: Int, child: Int) -> Bool {
        if child == 0 {
            return false
        } else if child == parent {
            return true
        } else {
            let par = jointParents[child]
            
            return par == parent || isJointDescendantOf(parent: parent, child: par)
        }
    }
    
    
    
    /// Returns a position for every joint in [0, n).
    func getPositions() -> [Vec2] {
        
        // Use dynamic programming to avoid repeating computations.
        var positions: [Vec2?] = [Vec2?](repeating: nil, count: numJoints)
        
        
        for index in 0..<numJoints {
            positions[index] = getPositionOf(joint: index, withKnownPositions: &positions)
        }
        
        return positions.map { $0! }
    }
    
    /// Precondition: there are no cycles in the model tree
    /// Returns the position of a particular joint given that some positions may be known
    func getPositionOf(joint: Int, withKnownPositions positions: inout [Vec2?]) -> Vec2 {
        if positions[joint] != nil {
            return positions[joint]!
        } else {
            
            // If joint isn't the root joint...
            if joint != 0 {
                
                // Compute the position of the joint based on its parent
                let parent1 = jointParents[joint]
                let parent2 = jointParents[parent1]
                
                let refDif: Vec2
                
                let parent1Pos = getPositionOf(joint: parent1, withKnownPositions: &positions)
                
                // If parent2 != -1 then we can compute a direction.
                if parent2 != -1 {
                    let parent2Pos = getPositionOf(joint: parent2, withKnownPositions: &positions)
                    
                    refDif = (parent1Pos - parent2Pos).normalized
                } else {
                    // otherwise, parent1 is root, so use root direction
                    refDif = rootReferenceDir
                }
                
                
                
                // Position of the joint is equal to its parent's position + the parent's reference direction
                // rotated by the joint's angle.
                positions[joint] = parent1Pos + jointDistances[joint] * refDif.rotatedCCW(theta: jointAngles[joint])
                
                return positions[joint]!
            } else {
                // Otherwise, we're the root, so just return that!
                positions[joint] = rootPosition
                return rootPosition
            }
        }
    }
}
