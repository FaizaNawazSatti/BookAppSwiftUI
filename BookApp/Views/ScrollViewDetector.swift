//
//  ScrollViewDetector.swift
//  BookApp
//
//  Created by Azmat Ali Akhtar on 17/04/2023.
//

import SwiftUI

struct ScrollViewDetector:UIViewRepresentable {
    @Binding var carouselMode : Bool
    var totalCardCount : Int
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent : self)
    }
    func makeUIView(context: Context) -> UIView {
        
        return UIView()
        
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
        DispatchQueue.main.async {
            if let scrollView = uiView.superview?.superview?.superview as? UIScrollView {
                
                scrollView.decelerationRate = carouselMode ? .fast : .normal
                scrollView.delegate = (carouselMode) ? context.coordinator : nil
                context.coordinator.totalCount =  totalCardCount
            }
        }
        
    }
    class Coordinator: NSObject, UIScrollViewDelegate {
        
        var parent: ScrollViewDetector
        
        
        
        init(parent: ScrollViewDetector) {
            
            self.parent = parent
            
        }
        
        var totalCount: Int = 0
        var velocityY : CGFloat = 0
        
        func scrollViewWillEndDragging (_ scrollView: UIScrollView, withVelocity velocity : CGPoint, targetContentOffset:UnsafeMutablePointer<CGPoint>) {
            let cardHeight: CGFloat = 220
            
            let cardSpacing: CGFloat = 35
            
            /// Adding velocity for more natural feel
            
            let targetEnd: CGFloat = scrollView.contentOffset.y + (velocity.y * 60)
            
            let index = (targetEnd / cardHeight).rounded()
            
            let modifiedEnd = index * cardHeight
            
            let spacing = cardSpacing * index
            
            if !scrollView.isDecelerating{
                targetContentOffset.pointee.y = modifiedEnd + spacing
                velocityY = (velocity.y)
            }
            
            
        }
        
        
        /// Removing Invalid Scroll Position's
        
        
        
        func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
            
            /// Removing Invalid Scroll Position's
            
            let cardHeight: CGFloat = 220
            
            let cardSpacing: CGFloat = 35
            
            /// Adding velocity for more natural feel
            
            let targetEnd: CGFloat = scrollView.contentOffset.y + (velocityY * 60)
            
            let index = max(min((targetEnd / cardHeight).rounded() , CGFloat(totalCount)),0.0)
            
            let modifiedEnd = index * cardHeight
            
            let spacing = cardSpacing * index
            
            scrollView.setContentOffset(.init(x: 0, y: modifiedEnd + spacing), animated: true)
            
        }
        
    }
    
}

