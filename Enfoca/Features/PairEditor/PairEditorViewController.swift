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
    @IBOutlet weak var deleteButton: UIButton!
    
    var wordPair : WordPair?
    var selectedTags: [Tag] = []
    var delegate: PairEditorDelegate!
    var gender: Gender {
        get{
            if genderSegmentedControl.selectedSegmentIndex == UISegmentedControlNoSegment {
                return .notset
            }
            return genderSegmentedControl.selectedSegmentIndex == 0 ? .masculine : .feminine
        }
        set {
            guard let _ = genderSegmentedControl else {
                return //Happens in some unit tests.
            }
            
            switch newValue {
            case .notset:
                genderSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
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
            saveOrCreateButton?.setTitle("Create", for: .normal)
            updateTagSummary(tags: selectedTags)
            deleteButton?.isHidden = true
        }
    }
    
    @IBAction func performBackButtonAction(){
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tagButtonAction(_ source: UIButton) {
        performSegue(withIdentifier: "TagEditorSegue", sender: selectedTags)
    }
    @IBAction func performDeleteButton(_ sender: Any) {
        guard let wordPair = wordPair else { return }
        getAppDelegate().webService.deleteWordPair(wordPair: wordPair, callback: { (wordPair : WordPair?, error: EnfocaError?) in
            
            if let error = error {
                self.presentAlert(title : "Network Error", message : error)
            } else {
                print("Deleted \(wordPair?.pairId)")
            }
        })
    }

    func configureForEdit(wordPair wp: WordPair){
        self.wordPair = wp
        selectedTags = wp.tags
        
        saveOrCreateButton?.setTitle("Save", for: .normal)
        wordTextField?.text = wp.word
        definitionTextField?.text = wp.definition
        updateTagSummary(tags: selectedTags)
        gender = wp.gender
        deleteButton?.isHidden = false
    }
    
    func updateTagSummary(tags: [Tag]){
        let tagsAsText = tags.tagsToText()
        if !tagsAsText.isEmpty {
            tagSummaryLabel?.text = tagsAsText
        } else {
            tagSummaryLabel?.text = "Tags: (none)"
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
    @IBAction func saveOrCreateAction(_ sender: UIButton) {
    
        let word = wordTextField.text!
        let definition = definitionTextField.text!
        
        if wordPair == nil {
            //Create
            if let error = validateForCreate() {
                presentAlert(title : "Validation Error", message : error)
                return
            }
            getAppDelegate().webService.showNetworkActivityIndicator = true
            getAppDelegate().webService.createWordPair(word: word, definition: definition, tags: selectedTags, gender: gender, example: exampleTextView.text, callback: { (wordPair : WordPair?, error: EnfocaError?) in
                
                getAppDelegate().webService.showNetworkActivityIndicator = false
                guard let newWordPair = wordPair else {
                    //handle error
                    self.presentAlert(title : "Network Error", message : error!)
                    return
                }
                self.delegate.added(wordPair: newWordPair)
                self.performBackButtonAction()
            })
        } else {
            //Update
            if let error = validateForUpdate() {
                presentAlert(title : "Validation Error", message : error)
                return
            }
            getAppDelegate().webService.showNetworkActivityIndicator = true
            getAppDelegate().webService.updateWordPair(oldWordPair: wordPair!, word: word, definition: definition, gender: gender, example: exampleTextView.text, tags: selectedTags, callback: { (wordPair : WordPair?, error: EnfocaError?) in
                    getAppDelegate().webService.showNetworkActivityIndicator = false
                    guard let updatedWordPair = wordPair else {
                        //handle error
                        self.presentAlert(title : "Network Error", message : error!)
                        return
                    }
                    self.delegate.updated(wordPair: updatedWordPair)
                    self.performBackButtonAction()
            })
        }
    }
    
    
    
    private func validateForCreate() -> String?{
        if (wordTextField.text ?? "").isEmpty {
            return "Word pair not created.  Word is blank or empty."
        }
        if (definitionTextField.text ?? "").isEmpty {
            return "Word pair not created.  Definiton can not be blank."
        }
        return nil
    }
    
    private func validateForUpdate() -> String?{
        if (wordTextField.text ?? "").isEmpty {
            return "Word pair not saved.  Word is blank or empty."
        }
        if (definitionTextField.text ?? "").isEmpty {
            return "Word pair not saved.  Definiton can not be blank."
        }
        
        return nil //success
    }
    
    
}

extension PairEditorViewController : TagFilterDelegate {
    
    func tagFilterUpdated(_ callback: (() -> ())?) {
        updateTagSummary(tags: selectedTags)
    }
    
}

extension PairEditorViewController : UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        //Pretty sure this is only called on iphone.  This is to force iPhone to show this as a popover style modal instead of full screen.
        return UIModalPresentationStyle.none
    }
}

