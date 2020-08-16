//
//  ViewController.swift
//  MOSheetTransition
//
//  Created by MunokKim on 08/17/2020.
//  Copyright (c) 2020 MunokKim. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBAction func presentButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewController2") as! ViewController2
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = vc.transitionController
        
        present(vc, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

