//
//  PairEditorViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 1/14/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

class PairEditorViewController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var wordTextField: UITextField!
    @IBOutlet weak var definitionTextField: UITextField!
    @IBOutlet weak var saveOrCreateButton: UIButton!
    
    var wordPair : WordPair?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let wordPair = wordPair {
            configureForEdit(wordPair: wordPair)
        } else {
            saveOrCreateButton.setTitle("Create", for: .normal)
        }
    }
    
    @IBAction func performBackButtonAction(){
        _ = navigationController?.popViewController(animated: true)
    }

    private func configureForEdit(wordPair wp: WordPair){
        self.wordPair = wp
        saveOrCreateButton.setTitle("Save", for: .normal)
        wordTextField.text = wp.word
        definitionTextField.text = wp.definition
    }
}
