/*
 * This represents the single Note detail screen
 * You can view note details and/or edit the note title or content
 */
import UIKit
import Foundation
import CoreData

class DetailViewController: UIViewController {
    
    @IBOutlet weak var noteContent: UITextView!
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var noteTitle: UITextField!
    
    // Assign all the textfields to this action for keyboard collapse
    @IBAction func resignKeyboardTextField(sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    static var guid: String?
    
    //Timer! Property for auto-saving of a note
    var autoSaveTimer: Timer!
    
    var notes: [NSManagedObject] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        //Start the auto-save timer
        autoSaveTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(autoSave), userInfo: nil, repeats: true)
        
        //noteContent.layer.borderColor = UIColor.darkGray as! CGColor
        noteTitle.layer.borderWidth = 0.5
        noteTitle.layer.cornerRadius = 5
        
        noteContent.layer.borderWidth = 0.5
        noteContent.layer.cornerRadius = 5
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }
    
    // Display the note title and content
    func configureView() {
        print("Note GUID: \(DetailViewController.guid ?? "nil")")
        
        if let title = noteDetail?.value(forKey: "title") as? String {
            noteTitle?.text = title
        }
        
        if let content = noteDetail?.value(forKey: "content") as? String {
            noteContent?.text = content
        }
    }
    
    func autoSave() {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        // 1
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        // 2
        let entity =
            NSEntityDescription.entity(forEntityName: "Note",
                                       in: managedContext)!
        
        let myNote = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        
        // 3
        if (DetailViewController.guid == nil)
        {
            print("Note GUID: \(DetailViewController.guid ?? "nil")")
            DetailViewController.guid = NSUUID().uuidString
        }
        
        print("Note GUID: \(DetailViewController.guid ?? "nil")")
        myNote.setValue(DetailViewController.guid, forKeyPath: "guid")
        
        myNote.setValue(noteTitle.text, forKeyPath: "title")
        myNote.setValue(noteContent.text, forKeyPath: "content")
        myNote.setValue(NSDate(), forKeyPath: "dateUpdated")
        
        // 4
        do {
            try managedContext.save()
            notes.append(myNote)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        print("Auto Saved")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        autoSaveTimer.invalidate()
        DetailViewController.guid = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Dismiss keyboard when user taps on view
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Dismiss keyboard when user taps the return key on the keyboard after editing title
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    var noteDetail: Note? {
        didSet {
            DetailViewController.guid = noteDetail?.value(forKey: "guid") as! String
            // Update the view.
            configureView()
        }
    }
}

