//
//  MoviesViewController.swift
//  Playing
//
//  Created by Daniel on 2/15/16.
//  Copyright © 2016 Notabela. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var noInternetView: UIView!
    var noInternet: Bool = false
    
    var movies: [NSDictionary]?
    var filteredMovies: [NSDictionary]!
    var searchController: UISearchController!
    var endpoint:String!
    
    //Set Rows in TableView
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let movie = filteredMovies![indexPath.row]
        let title = movie["title"] as? String
        let description = movie["overview"] as? String
        let cell = tableView.dequeueReusableCellWithIdentifier("movieCell", forIndexPath: indexPath) as? movieCell
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        
        if let posterPath = movie["poster_path"] as? String
        {
        
            let imageURL = NSURL(string: baseUrl + posterPath)
            let imageRequest = NSURLRequest(URL: imageURL!)
        
            cell?.posterView.setImageWithURLRequest(
                imageRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                
                    // imageResponse will be nil if the image is cached
                    if imageResponse != nil {
                        //print("Image was NOT cached, fade in image")
                        cell?.posterView.alpha = 0.0
                        cell?.posterView.image = image
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            cell?.posterView.alpha = 1.0
                        })
                    } else {
                        //print("Image was cached so just update the image")
                        cell?.posterView.image = image
                    }
                },
                failure: { (imageRequest, imageResponse, error) -> Void in
                    // do something for the failure condition
            })
        }
            
        cell?.titleLabel.text = title
        cell?.titleLabel.sizeToFit()
        cell?.descripLabel.text = description
        cell?.descripLabel.sizeToFit()
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 0, green: 100, blue: 255, alpha: 0.3)
        cell?.selectedBackgroundView = backgroundView
        
        return cell!
    }
    
    //Conform to UITableView Delegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = filteredMovies
        {
            return movies.count
        } else
        {
            return 0
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        if let searchText = searchController.searchBar.text
        {
            filteredMovies = searchText.isEmpty ? movies : movies?.filter(
                {(dataString: NSDictionary) -> Bool in
                return (dataString["title"] as! String).rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
                }
            )
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        noInternetView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        
        //Implementing a Search Bar
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        
        //navigationItem.titleView = searchController.searchBar
        searchController.hidesNavigationBarDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
        
        //Add a UIRefreshControl
        let refreshControl = UIRefreshControl()
        
        //Nav Bar
        self.navigationItem.title = "Movies"
        
        //bind Action to refresh control and bind it to tableView so it runs anytime refreshcontrol is called
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 1)
        
        //Check for Internet Connection
        if Reachability.isConnectedToNetwork() == true
        {
            if noInternet
            {
                noInternetView.removeFromSuperview()
                noInternet = false
            }
            
            print("Internet connection OK")
        }
            
        else
        {
            addNoInternetView()
            noInternet = true
            print("Internet connection FAILED")
        }
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        //Show progress HUD before we fire up network request
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                
                //Hide Progress HUD after the data has been retrieved
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            print("response: \(responseDictionary)")
                        self.movies = responseDictionary["results"] as? [NSDictionary]
                        self.filteredMovies = self.movies
                        self.tableView.reloadData()
                    }
                }
        })
        task.resume()
    }
    
    //Add a No internet Banner
    func addNoInternetView()
    {
        view.addSubview(noInternetView)
        
        let bottomConstraint = noInternetView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor)
        let leftConstraint = noInternetView.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
        let rightConstraint = noInternetView.rightAnchor.constraintEqualToAnchor(view.rightAnchor)
        let heightConstraint = noInternetView.heightAnchor.constraintEqualToConstant(44)
        
        //pack all those constrianst into a layout constraint and activate
        NSLayoutConstraint.activateConstraints([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])

        //layout the view if needed
        view.layoutIfNeeded()
    }
    
    //Get New Data
    func refreshControlAction(refreshControl: UIRefreshControl)
    {
        //Check for Internet Connection
        if Reachability.isConnectedToNetwork() == true
        {
            if noInternet
            {
                noInternetView.removeFromSuperview()
                noInternet = false
            }
            
            print("Internet connection OK")
        }
            
        else
        {
            addNoInternetView()
            noInternet = true
            print("Internet connection FAILED")
        }
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        //MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                
                //MBProgressHUD.hideHUDForView(self.view, animated: true)
                
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            print("response: \(responseDictionary)")
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            
                            self.tableView.reloadData()
                    }
                }
            
                refreshControl.endRefreshing() //Tell refresh Control to end refreshing
        })
        task.resume()
        
    }
    
    //Pass on Data from Touched Cell to a destination Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        let movie = filteredMovies![indexPath!.row]
        
        let detailViewController = segue.destinationViewController as? DetailViewController
        detailViewController?.movie = movie
    }

}
