//
//  ClusterAnnotationView.swift
//  SoundWorld
//
//  Created by Jason Goodney on 10/31/18.
//  Copyright © 2018 Jason Goodney. All rights reserved.
//

import MapKit

class ClusterAnnotationView: MKAnnotationView {

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        collisionMode = .circle
        centerOffset = CGPoint(x: 0, y: -10) // Offset center point to animate better with marker annotations
        canShowCallout = true
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        
        if let cluster = annotation as? MKClusterAnnotation {
            let totalPeople = cluster.memberAnnotations.count
            
            image = drawPeopleCount(totalPeople)
            
            if totalPeople > 0 {
                displayPriority = .defaultLow
            } else {
                displayPriority = .defaultHigh
            }
        }
        
        
    }
    
    private func drawPeopleCount(_ count: Int) -> UIImage {
        return drawRatio(to: count)
    }
    
    private func drawRatio(to whole: Int, fillColor: UIColor = UIColor.Theme.primaryBackground) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 40, height: 40))
        return renderer.image(actions: { _ in
            // Fill full circle with wholeColor
            fillColor.setFill()
            UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 40, height: 40)).fill()

            // Finally draw count text vertically and horizontally centered
            let attributes = [ NSAttributedString.Key.foregroundColor: UIColor.Theme.primary,
                               NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)]
            let text = "\(whole)"
            let size = text.size(withAttributes: attributes)
            let rect = CGRect(x: 20 - size.width / 2, y: 20 - size.height / 2, width: size.width, height: size.height)
            text.draw(in: rect, withAttributes: attributes)
        })
    }
}
