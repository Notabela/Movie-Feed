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

class MoviesViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchResultsUpdating {
    
    //Views
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var noInternetView: UIView!
    
    //global Variables
    var movies: [NSDictionary]?
    var filteredMovies: [NSDictionary]!
    var searchController: UISearchController!
    var endpoint:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //view setups
        self.view.backgroundColor = UIColor(red: 120, green: 120, blue: 120, alpha: 0.1)
        self.navigationItem.title = "Movies"
        
        setupCollectionView()
        setupSearchBar()
        getData()
    }
    
    //MARK: CollectionView Functions
    
    private func setupCollectionView()
    {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerNib(UINib(nibName: "movieCollectionCell", bundle: nil), forCellWithReuseIdentifier: "movieCell")
        
        //specify direction of scroll
        flowLayout.scrollDirection = .Vertical
        
        //Set the spacing between our elements - just play around with it cos IDEK
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        collectionView.backgroundColor = UIColor(red: 120, green: 120, blue: 120, alpha: 0.1)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let movie = filteredMovies![indexPath.row]
        let title = movie["title"] as? String
        //let description = movie["overview"] as? String
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("movieCell", forIndexPath: indexPath) as? movieCollectionCell
        
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
        
        cell?.titleView.text = title
        return cell!
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredMovies?.count ?? 0
    }
    
    
    //MARK: SearchBar Functions
    
    private func setupSearchBar()
    {
        //Implementing a Search Bar
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        
        navigationItem.titleView = searchController.searchBar
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.titleView = searchController.searchBar
        self.definesPresentationContext = true
        
        //Add a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.yellowColor()
        
        //bind Action to refresh control and bind it to tableView so it runs anytime refreshcontrol is called
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        collectionView.insertSubview(refreshControl, aboveSubview: collectionView)
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        if let searchText = searchController.searchBar.text
        {
            filteredMovies = searchText.isEmpty ? movies : movies?.filter(
                {(dataString: NSDictionary) -> Bool in
                return (dataString["title"] as! String).rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
                }
            )
            collectionView.reloadData()
        }
    }
    
    //Get New Data
    func refreshControlAction(refreshControl: UIRefreshControl)
    {
        //Check for Internet Connection
        checkInternetConnection()
        
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
                            //print("response: \(responseDictionary)")
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            
                            self.collectionView.reloadData()
                    }
                }
            
                refreshControl.endRefreshing() //Tell refresh Control to end refreshing
        })
        task.resume()
    }
    
    //MARK: Segue to DetailViewController
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        performSegueWithIdentifier("detailSegue", sender: cell)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let cell = sender as! UICollectionViewCell
        let indexPath = collectionView.indexPathForCell(cell)
        let movie = filteredMovies![indexPath!.row]
        
        let detailViewController = segue.destinationViewController as? DetailViewController
        detailViewController?.movie = movie
    }
    
    
    //MARK: Private functions
    
    private func getData()
    {
        checkInternetConnection()
        
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
                            //print("response: \(responseDictionary)")
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            self.filteredMovies = self.movies
                            self.collectionView.reloadData()
                    }
                }
        })
        task.resume()
    }
    
    //check for internet connection
    private func checkInternetConnection(){
        
        if Reachability.isConnectedToNetwork() && !noInternetView.hidden {
            
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.noInternetView.center.y -= self.noInternetView.frame.height
                    
                    }, completion: { (finished: Bool) -> Void in
                        self.noInternetView.hidden = true
                })
            
        } else if !Reachability.isConnectedToNetwork() && noInternetView.hidden {
            
            
            noInternetView.hidden = false
            let defaultCenter = self.noInternetView.center.y
            self.noInternetView.center.y -= self.noInternetView.frame.height
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.noInternetView.center.y = defaultCenter
            })
        }
        
    }

    @IBAction func onTapNetworkError(sender: UITapGestureRecognizer) {
        getData()
    }
}
