//
//  MasterViewController.swift
//  Project5
//
//  Created by Martynas Jankauskas on 01/05/16.
//  Copyright © 2016 Martynas Jankauskas. All rights reserved.
//

import UIKit
import GameKit

class MasterViewController: UITableViewController {

    var objects = [String]()
    var allWords = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(self.promptForAnswer))
        
        if let path = NSBundle.mainBundle().pathForResource("start", ofType: "txt") {
            print("found file")
            if let words = try? String(contentsOfFile: path) {
                allWords = words.componentsSeparatedByString("\n")
            }
        } else {
            allWords = ["no strings found"]
        }
        
        startGame()
        

    }
    
    func startGame() {
        // make a new shuffled array of words
        allWords = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(allWords) as! [String]
        title = allWords[0]
        // remove user data and reload tableview
    }
    
    func promptForAnswer() {
        let ac = UIAlertController(title: "Please submit answer", message: nil, preferredStyle: .Alert)
        ac.addTextFieldWithConfigurationHandler(nil)
        
        // Trailing closure syntax
        let submitAction = UIAlertAction(title: "Submit", style: .Default) {
            // this is for memory management, to tell "weak" or "unowned" references
            [unowned self, ac]
            action in
            let answer = ac.textFields![0].text!
            self.submitAnswer(answer)
            
        }
        ac.addAction(submitAction)
        presentViewController(ac, animated: true, completion: nil)
    }
    
    func submitAnswer(answer: String) {
        let lowerAnswer = answer.lowercaseString
        var errorTitle: String
        if wordIsPossible(lowerAnswer) {
            if wordIsOriginal(lowerAnswer) {
                if wordIsReal(lowerAnswer) {
                    objects.insert(lowerAnswer, atIndex: 0)
                    let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                    tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                    return
                } else {
                    errorTitle = "There is no such word in English"
                }
            } else {
                errorTitle = "This word is already one of your answers"
            }
        } else {
            errorTitle = "Bad combination"
        }
        
        let ac = UIAlertController(title: errorTitle, message: nil, preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(ac, animated: true, completion: nil)
        
    }
    
    // MARK: - word check 
    
    func wordIsPossible(word: String) -> Bool {
        var originalWord = self.title!.lowercaseString
        
        for letter in word.characters {
            if let pos = originalWord.rangeOfString(String(letter)) {
                originalWord.removeAtIndex(pos.startIndex)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func wordIsOriginal(word: String) -> Bool {
        return !objects.contains(word)
    }
    
    func wordIsReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSMakeRange(0, word.characters.count)
        let misspelledRange = checker.rangeOfMisspelledWordInString(word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues
    

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath)

        let word = objects[indexPath.row]
        cell.textLabel!.text = word
        return cell
    }


}

