//
//  ViewController2.swift
//  MOSheet
//
//  Created by 김문옥 on 2020/08/09.
//  Copyright © 2020 MunokKim. All rights reserved.
//

import UIKit
import MOSheetTransition
import Combine

class ViewController2: UIViewController {
    
    @IBAction func dismissButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    lazy var transitionController: SheetTransitionController = SheetTransitionController(for: self)
    
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        transitionController.transitioningState
            .sink { (state) in
                print(state)
        }
            .store(in: &cancellables)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
