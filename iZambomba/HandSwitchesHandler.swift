//
//  HandSwitches.swift
//  iZambomba
//
//  Created by SingularNet on 11/12/18.
//  Copyright © 2018 singularfactory. All rights reserved.
//

import UIKit

class HandSwitchesHandler: UIStackView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    //MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStackView()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupStackView()
    }
    
    //MARK: Private methods
    private func setupStackView() {
        //Labels
        let rightHandLabel = UILabel()
        rightHandLabel.text = "Hola"
        let leftHandLabel = UILabel()
        let otherHandLabel = UILabel()
        
        //Switches
        let rightHandSwitch = UISwitch()
        let leftHandSwitch = UISwitch()
        let otherHandSwitch = UISwitch()
        
        //StackViews
        let firstHorizontalSV = UIStackView()
            firstHorizontalSV.axis = .horizontal
            firstHorizontalSV.distribution = .equalSpacing
            firstHorizontalSV.alignment = .center
            firstHorizontalSV.spacing = 40
            firstHorizontalSV.addArrangedSubview(rightHandLabel)
            firstHorizontalSV.addArrangedSubview(rightHandSwitch)
        
        let secondHorizontalSV = UIStackView()
            secondHorizontalSV.axis = .horizontal
            secondHorizontalSV.distribution = .equalSpacing
            secondHorizontalSV.alignment = .center
            secondHorizontalSV.spacing = 40
            secondHorizontalSV.addArrangedSubview(leftHandLabel)
            secondHorizontalSV.addArrangedSubview(leftHandSwitch)
        
        let thirdHorizontalSV = UIStackView()
            thirdHorizontalSV.axis = .horizontal
            thirdHorizontalSV.distribution = .equalSpacing
            thirdHorizontalSV.alignment = .center
            thirdHorizontalSV.spacing = 40
            thirdHorizontalSV.addArrangedSubview(otherHandLabel)
            thirdHorizontalSV.addArrangedSubview(otherHandSwitch)
        
        let wholeVerticalStackView = UIStackView()
            wholeVerticalStackView.axis = .vertical
            wholeVerticalStackView.distribution = .equalSpacing
            wholeVerticalStackView.alignment = .center
            wholeVerticalStackView.spacing = 40
        wholeVerticalStackView.addArrangedSubview(firstHorizontalSV)
        wholeVerticalStackView.addArrangedSubview(secondHorizontalSV)
        wholeVerticalStackView.addArrangedSubview(thirdHorizontalSV)
        
        
        
    }
    
}
