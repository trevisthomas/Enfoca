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
    var selectedTags: [Tag] = []
    var delegate: PairEditorDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        initialize()
    }
    
    func initialize(){
        
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
        performSegue(withIdentifier: "TagEditorSegue", sender: selectedTags)
    }

    func configureForEdit(wordPair wp: WordPair){
        self.wordPair = wp
        selectedTags = wp.tags
        
        saveOrCreateButton?.setTitle("Save", for: .normal)
        wordTextField?.text = wp.word
        definitionTextField?.text = wp.definition
        
        updateTagSummary(tags: selectedTags)
        
    }
    
    func updateTagSummary(tags: [Tag]){
        let tagsAsText = tags.tagsToText()
        if !tagsAsText.isEmpty {
            tagSummaryLabel?.text = tagsAsText
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destVC = segue.destination as? TagFilterViewController {
            destVC.tagFilterDelegate = self
            
            destVC.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover: UIPopoverPresentationController = destVC.popoverPresentationController!
            popover.delegate = self
            popover.sourceRect = tagButton.frame
            popover.permittedArrowDirections = [.left, .right]
        }
    }
    
    @IBAction func saveOrCreateAction(_ sender: Any) {
        
        //TODO Validate!!
        let word = wordTextField.text!
        let definition = definitionTextField.text!
        
        if wordPair == nil {
//            getAppDelegate().webService.createWordPair(word: word, definition: definition, tags: selectedTags, callback: { (newWordPair : WordPair) in
//                self.delegate.added(wordPair: newWordPair)
//            })
            
            getAppDelegate().webService.createWordPair(word: "", definition: "", tags: selectedTags, callback: { (newWordPair : WordPair) in
                self.delegate.added(wordPair: newWordPair)
            })
        } else {
            getAppDelegate().webService.updateWordPair(oldWordPair: wordPair!, word: word, definition: definition, tags: selectedTags, callback: { (updatedWordPair : WordPair) in
                    self.delegate.updated(wordPair: updatedWordPair)
            })
        }
        
    }
}

extension PairEditorViewController : TagFilterDelegate {
    
    func updated(_ callback: (() -> ())?) {
        updateTagSummary(tags: selectedTags)
    }
    
}

extension PairEditorViewController : UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        //Pretty sure this is only called on iphone.  This is to force iPhone to show this as a popover style modal instead of full screen.
        return UIModalPresentationStyle.none
    }
}

