//
//  ResponseTableViewController.swift
//  srvup
//
//  Created by Justin Mitchel on 6/25/15.
//  Copyright (c) 2015 Coding for Entrepreneurs. All rights reserved.
//

import UIKit
import SwiftyJSON

class ResponseTableViewController: UITableViewController, UITextViewDelegate {
    var lecture: Lecture?
//    var webView = UIWebView()
    var commentText:String?
    var commentID:Int?
    var commentUser:String?
    var commentChidren = [JSON]()
    var message = UITextView()
    let textArea = UITextView()
    let textAreaPlaceholder = "Your comment here..."
    let aRefeshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btn = UINavButton(title: "Back", direction: .Right, parentView: self.view)
        btn.addTarget(self, action: "popView:", forControlEvents: UIControlEvents.TouchUpInside)
        btn.frame.origin.y = btn.frame.origin.y - 10
        self.view.addSubview(btn)
        
        let newCommentBtn = UINavButton(title: "Reply", direction: .Left, parentView: self.view)
        newCommentBtn.addTarget(self, action: "scrollToFooter:", forControlEvents: UIControlEvents.TouchUpInside)
        newCommentBtn.frame.origin.y = btn.frame.origin.y
        self.view.addSubview(newCommentBtn)
        
        let headerView = UIView()
        headerView.frame = CGRectMake(0, 0, self.view.frame.width, 395)
        headerView.backgroundColor = .whiteColor()
        
        
        
        let headerTextView = UITextView()
        headerTextView.frame = CGRectMake(0, btn.frame.origin.y, self.view.frame.width, btn.frame.height)
        headerTextView.text = "Reply to comment"
        headerTextView.textColor = .blackColor()
        headerTextView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        headerTextView.textAlignment = .Center
        headerTextView.font = UIFont.boldSystemFontOfSize(26)
        headerTextView.editable = false
        headerTextView.scrollEnabled = false
        
        headerView.addSubview(headerTextView)
        
        
        let offset = CGFloat(10)
        
        let commentText = UITextView()
        commentText.frame = CGRectMake(0, headerTextView.frame.origin.y + headerTextView.frame.height + offset, headerTextView.frame.width, 30)
        commentText.text = self.commentText
        commentText.backgroundColor = UIColor(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1.0)
        commentText.font = UIFont.systemFontOfSize(16)
        
        let contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        commentText.contentInset = contentInset
        commentText.editable = true
        commentText.scrollEnabled = false
        commentText.sizeToFit()
        commentText.frame.size.width = headerView.frame.width
        
        headerView.addSubview(commentText)
        
        let viaText = UITextView()
        viaText.frame = CGRectMake(0, commentText.frame.origin.y + commentText.frame.height, self.view.frame.width, 30)
        if self.commentUser != nil {
            viaText.text = "via \(self.commentUser!)"
        }
        viaText.textAlignment = .Right
        viaText.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        viaText.editable = false
        viaText.scrollEnabled = false
        
        headerView.addSubview(viaText)
        
        var reponseTextHeight = CGFloat(0)
        
        if self.commentChidren.count > 0 {
            let reponseText = UITextView()
            reponseText.frame = CGRectMake(0, viaText.frame.origin.y + viaText.frame.height + offset, self.view.frame.width, 30)
            reponseText.text = "Replies"
            reponseText.font = UIFont.boldSystemFontOfSize(16)
            reponseText.contentInset = contentInset
            reponseText.editable = false
            reponseText.scrollEnabled = false
            reponseTextHeight = reponseText.frame.height
            
            headerView.addSubview(reponseText)
        }
 
        headerView.frame.size.height = btn.frame.height + commentText.frame.height + btn.frame.origin.y + (offset * 3) + viaText.frame.height + reponseTextHeight
        
        self.tableView.tableHeaderView = headerView
        
        
        
        let commentForm = UICommentForm(parentViewController: self, textArea: self.textArea, textAreaPlaceholder: self.textAreaPlaceholder, textAreaDelegate:self, formAction: "commentFormAction:")
        self.tableView.tableFooterView = commentForm
        
        
        
        
        
        self.aRefeshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.aRefeshControl.addTarget(self, action: "updateItems:", forControlEvents: UIControlEvents.ValueChanged)
        self.view.addSubview(self.aRefeshControl)
        
        
        
        
    
        let commentLabel = UILabel()
//        commentLabel.frame = CGRectMake(self.webView.frame.origin.x, self.webView.frame.origin.y + self.webView.frame.height + 10, self.webView.frame.width, 50)
        commentLabel.text = "Comments"
        commentLabel.font = UIFont.boldSystemFontOfSize(16)
        
        headerView.addSubview(commentLabel)
//        headerView.addSubview(self.webView)
//        
        
    }
    
    func updateItems(sender:AnyObject) {
        self.lecture?.updateLectureComments({ (success) -> Void in
            if success {
                println("grabbed comment successfully")
                self.aRefeshControl.endRefreshing()
                self.tableView.reloadData()
            } else {
                Notification().notify("Error updated data", delay: 2.0, inSpeed: 0.7, outSpeed: 2.5)
                self.aRefeshControl.endRefreshing()
            }
        })
    }
    

    
    
    func textViewDidBeginEditing(textView: UITextView) {
        self.message.text = ""
        if textView.text == self.textAreaPlaceholder {
            textView.text = ""
        }
        self.scrollToFooter(self)
    }
    
    func commentFormAction(sender: AnyObject) {
        let tag = sender.tag
        
        switch tag {
        case 1:
            if self.textArea.text != "" && self.textArea.text != self.textAreaPlaceholder {
                self.textArea.endEditing(true)
                self.lecture!.addComment(self.textArea.text, parent:self.commentID!, completion: addCommentCompletionHandler)
                self.textArea.text = self.textAreaPlaceholder
            } else {
                self.message.text = "A comment is required."
            }
        default:
            // println("cancelled")
            // self.commentView.removeFromSuperview()
            self.textArea.endEditing(true)
            self.backToTop(self)
            
        }
    }
    
    func addCommentCompletionHandler(success:Bool, dataSent:JSON?) -> Void {
        if !success {
            self.scrollToFooter(self)
            Notification().notify("Failed to add", delay: 2.5, inSpeed: 0.7, outSpeed: 1.2)
            
        } else {
            self.commentChidren.insert(dataSent!, atIndex: 0)
            
            Notification().notify("Message Added", delay: 1.5, inSpeed: 0.5, outSpeed: 1.0)
            self.scrollToTop({ (success) -> Void in
                if success{
                    self.tableView.reloadData()
                }
            })
            
        }
    }
    
    
 
    
    func backToTop(sender:AnyObject) {
        self.scrollToTop { (success) -> Void in
        }
    }
    
    // MARK: Scroll to Functions
    
    func scrollToTop(completion:(success:Bool) -> Void){
        let point = CGPoint(x: 0, y: -10)
        self.tableView.setContentOffset(point, animated: true)
        completion(success: true)
    }
    
    
    func scrollToFooter(sender:AnyObject) {
        let point = CGPoint(x: 0, y: self.tableView.tableFooterView!.frame.origin.y)
        self.tableView.setContentOffset(point, animated: true)
    }
    
    func popView(sender:AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
        // self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.commentChidren.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell
        
        // Configure the cell...
        let text = self.commentChidren[indexPath.row]["text"].string!
        let user = self.commentChidren[indexPath.row]["user"].string

        var newText = ""
        if user != nil {
            newText = "\(text) \n\nvia \(user!)"
        } else {
            newText = "\(text)"
        }
        
        cell.textLabel?.text = newText
        cell.textLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let text = self.commentChidren[indexPath.row]["text"].string!
        let user = self.commentChidren[indexPath.row]["user"].string
        
        var newText = ""
        if user != nil {
            newText = "\(text) \n\nvia \(user!)"
        } else {
            newText = "\(text)"
        }
        
        let cellFont = UIFont.boldSystemFontOfSize(14)
        let attrString = NSAttributedString(string: newText, attributes: [NSFontAttributeName : cellFont])
        let constraintSize = CGSizeMake(self.tableView.bounds.size.width, CGFloat(MAXFLOAT))
        let rect = attrString.boundingRectWithSize(constraintSize, options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        
        return rect.size.height + 50
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
}


/*
// Override to support conditional editing of the table view.
override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
// Return NO if you do not want the specified item to be editable.
return true
}
*/

/*
// Override to support editing the table view.
override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
if editingStyle == .Delete {
// Delete the row from the data source
tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
} else if editingStyle == .Insert {
// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
}
}
*/

/*
// Override to support rearranging the table view.
override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

}
*/

/*
// Override to support conditional rearranging of the table view.
override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
// Return NO if you do not want the item to be re-orderable.
return true
}
*/

/*
// MARK: - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
// Get the new view controller using [segue destinationViewController].
// Pass the selected object to the new view controller.
}
*/
}