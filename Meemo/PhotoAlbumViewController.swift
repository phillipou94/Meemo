//
//  PhotoAlbumViewController.swift
//  Meemo
//
//  Created by Phillip Ou on 5/14/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import UIKit

class PhotoAlbumViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var scrollView: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpScrollView()
        
        // Do any additional setup after loading the view.
    }
    
    func setUpScrollView() {
        self.scrollView.delegate = self
        self.scrollView.maximumZoomScale = 3.0
        self.scrollView.scrollEnabled = true
        self.scrollView.backgroundColor = UIColor.blackColor()
        
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewWillBeginZooming(scrollView: UIScrollView, withView view: UIView!) {
        
    }
    
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView!, atScale scale: CGFloat) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
