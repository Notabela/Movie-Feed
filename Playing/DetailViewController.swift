//
//  DetailViewController.swift
//  Playing
//
//  Created by Daniel on 2/26/16.
//  Copyright © 2016 Notabela. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController
{
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var overview: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoView: UIView!
    
    //implicitly unwrap
    var movie: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.height)
        
        let title = movie["title"] as? String
        titleLabel.text = title
        let details = movie["overview"] as? String
        overview.text = details
        
        overview.sizeToFit()
        
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
}
