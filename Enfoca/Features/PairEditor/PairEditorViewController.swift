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
    @IBOutlet weak var exampleTextView: UITextView!
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    
    var wordPair : WordPair?
    var selectedTags: [Tag] = []
    var delegate: PairEditorDelegate!
    var gender: Gender {
        get{
            guard genderSegmentedControl.isSelected else {
                return .notset
            }
            return genderSegmentedControl.selectedSegmentIndex == 0 ? .masculine : .feminine
        }
        set {
            guard let _ = genderSegmentedControl else {
                return //Happens in some unit tests.
            }
            
            genderSegmentedControl.isSelected = true
            switch newValue {
            case .notset:
                genderSegmentedControl.isSelected = false
            case .masculine:
                genderSegmentedControl.selectedSegmentIndex = 0
            case .feminine:
                genderSegmentedControl.selectedSegmentIndex = 1
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        initialize()
    }
    
    func initialize(){
        
        if let wordPair = wordPair {
            configureForEdit(wordPair: wordPair)
        } else {
            saveOrCreateButton.setTitle("Create", for: .normal)
            updateTagSummary(tags: selectedTags)
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
        gender = wp.gender
    }
    
    func updateTagSummary(tags: [Tag]){
        let tagsAsText = tags.tagsToText()
        if !tagsAsText.isEmpty {
            tagSummaryLabel?.text = tagsAsText
        } else {
            tagSummaryLabel.text = "Tags: (none)"
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
            getAppDelegate().webService.createWordPair(word: word, definition: definition, tags: selectedTags, gender: gender, example: exampleTextView.text, callback: { (wordPair : WordPair?, error: EnfocaError?) in
                guard let newWordPair = wordPair else {
                    //handle error
                    return
                }
                self.delegate.added(wordPair: newWordPair)
            })
        } else {
            getAppDelegate().webService.updateWordPair(oldWordPair: wordPair!, word: word, definition: definition, gender: gender, example: exampleTextView.text, tags: selectedTags, callback: { (wordPair : WordPair?, error: EnfocaError?) in
                    guard let updatedWordPair = wordPair else {
                        //handle error
                        return
                    }
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

