//
//  DetailViewController.swift
//  Playing
//
//  Created by Daniel on 2/26/16.
//  Copyright © 2016 Notabela. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    //outlets
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var overview: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoView: UIView!
    
    
    //global variables
    var movie: NSDictionary!
    var originalInfoViewCenter: CGPoint!
    var lowestInfoViewLoc: CGFloat!
    var highestInfoViewLoc: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //view setup
        self.view.backgroundColor = UIColor(red: 120, green: 120, blue: 120, alpha: 0.1)
        navigationController?.hidesBarsOnTap = true
        
        //set labels
        let title = movie["title"] as? String
        titleLabel.text = title

        let details = movie["overview"] as? String
        overview.text = details
        overview.sizeToFit()
        
        setupInfoView()
        setupPosterView()
    }
    
    override func viewWillDisappear(animated: Bool) {
        navigationController?.hidesBarsOnTap = false
    }
    
    func setupInfoView()
    {
        infoView.bounds.size.height = overview.frame.height + titleLabel.frame.height + 10
        infoView.frame.origin.y = CGFloat(2.3 * view.bounds.size.height / 3)
        lowestInfoViewLoc = infoView.center.y
        highestInfoViewLoc = (navigationController?.navigationBar.frame.height)! + (navigationController?.navigationBar.center.y)! + 120
        infoView.layer.cornerRadius = 5
        
    }
    
    func setupPosterView(){
        
        if let posterPath = movie["poster_path"] as? String
        {
            let lowBaseUrl = "http://image.tmdb.org/t/p/w45"
            let highBaseUrl = "http://image.tmdb.org/t/p/original"
            
            let smallImageRequest = NSURLRequest(URL: NSURL(string: lowBaseUrl + posterPath)!)
            let largeImageRequest = NSURLRequest(URL: NSURL(string: highBaseUrl + posterPath)!)
            
            posterImageView.setImageWithURLRequest(
                smallImageRequest,
                placeholderImage: nil,
                success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                    
                    // smallImageResponse will be nil if the smallImage is already available
                    // in cache (might want to do something smarter in that case).
                    self.posterImageView.alpha = 0.0
                    self.posterImageView.image = smallImage;
                    
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        
                        self.posterImageView.alpha = 1.0
                        
                        }, completion: { (sucess) -> Void in
                            
                            // The AFNetworking ImageView Category only allows one request to be sent at a time
                            // per ImageView. This code must be in the completion block.
                            self.posterImageView.setImageWithURLRequest(
                                largeImageRequest,
                                placeholderImage: smallImage,
                                success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                    
                                    self.posterImageView.image = largeImage;
                                    
                                },
                                failure: { (request, response, error) -> Void in
                                    // do something for the failure condition of the large image request
                                    // possibly setting the ImageView's image to a default image
                            })
                    })
                },
                failure: { (request, response, error) -> Void in
                    // do something for the failure condition
                    // possibly try to get the large image
            })
        }
    }
    
    @IBAction func onPanInfoViewup(sender: UIPanGestureRecognizer) {
        
        //Change in Movement since translation began
        let translation = sender.translationInView(view)
        
        //Case of Moving View Around
        if sender.state == UIGestureRecognizerState.Began{
            
            originalInfoViewCenter = infoView.center
            
        } else if sender.state == UIGestureRecognizerState.Changed {
            
            //Get original center, if it moves get the delta move and add it onto the location
            var center = originalInfoViewCenter
            center.y += translation.y
            center.y = center.y > lowestInfoViewLoc ? lowestInfoViewLoc : center.y
            center.y = center.y < highestInfoViewLoc ? highestInfoViewLoc : center.y
            infoView.center = center
        }
    }
    
}
