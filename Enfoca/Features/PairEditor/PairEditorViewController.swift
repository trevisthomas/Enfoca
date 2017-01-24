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
    @IBOutlet weak var tagSummaryLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    
    var wordPair : WordPair?
    var tags: [Tag] = []
    var selectedTags: [Tag] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tagSummaryLabel.text = "Tags: (none)"
        
        if let wordPair = wordPair {
            configureForEdit(wordPair: wordPair)
        } else {
            saveOrCreateButton.setTitle("Create", for: .normal)
        }
        
    }
    
    @IBAction func performBackButtonAction(){
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tagButtonAction(_ source: UIButton) {
        performSegue(withIdentifier: "TagEditorSegue", sender: self)
    }

    private func configureForEdit(wordPair wp: WordPair){
        self.wordPair = wp
        saveOrCreateButton.setTitle("Save", for: .normal)
        wordTextField.text = wp.word
        definitionTextField.text = wp.definition
        
        if let tagsAsText = wordPair?.tags.tagsToText() {
            if !tagsAsText.isEmpty {
                tagSummaryLabel.text = tagsAsText
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destVC = segue.destination as? TagFilterViewController {
            destVC.tagFilterDelegate = self
        }
    }
    
    
}

extension PairEditorViewController : TagFilterDelegate {
    
    func updated(_ callback: (() -> ())?) {
        
    }
    
    
}
