//
//  ComicsViewController.swift
//  Avengers
//
//  Created by Harpreet Singh on 05/10/23.
//

import UIKit
import Combine

class ComicsViewController: UIViewController {

    //MARK:Outlets
    @IBOutlet weak var comicsCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var paginationIndicator: UIActivityIndicatorView!
    @IBOutlet weak var releaseThisWeekImage: UIImageView!
    @IBOutlet weak var releaseLastWeekImage: UIImageView!
    @IBOutlet weak var releaseNextWeekImage: UIImageView!
    @IBOutlet weak var releaseThisMonthImage: UIImageView!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var filterButton: UIButton!
    
    //MARK: Variables
    private let viewModel = ComicsViewModel()
    private var cancellabels = Set<AnyCancellable>()
    private var comics:[ComicResult] = []{
        didSet{
            self.paginationIndicator.isHidden = true
            self.comicsCollectionView.reloadData()
            self.comicsCollectionView.layoutIfNeeded()
        }
    }
    private var limit = "20"
    private var offset = 0
    private var isLoading:Bool = false
    private var filterDates:String = ""
    @Published var selectedTag = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegates()
    }
    override func viewWillAppear(_ animated: Bool) {
        setUI()
        initViews()
        filterDates = ""
        activityIndicatorView.isHidden = false
        fetchComics(dates: filterDates)
    }
    override func viewWillLayoutSubviews() {
        self.comicsCollectionView.reloadData()
    }
    
    //MARKS: Actions
    @IBAction func tapFilterButton(_ sender: Any) {
        filterView.isHidden.toggle()
    }
    @IBAction func tappedFilterType(_ sender: UIButton) {
        selectedTag = sender.tag
        switch sender.tag{
        case 1:
            Constants.printToConsole("Tag 1")
            if let _ = releaseThisWeekImage.image{
                releaseThisWeekImage.image = nil
                selectedTag = 0
            }
            else{
                releaseThisWeekImage.image = UIImage(systemName: "checkmark.circle.fill")
                releaseLastWeekImage.image = nil
                releaseNextWeekImage.image = nil
                releaseThisMonthImage.image = nil
            }
        case 2:
            Constants.printToConsole("Tag 2")
            if let _ = releaseLastWeekImage.image{
                releaseLastWeekImage.image = nil
                selectedTag = 0
            }else{
                releaseLastWeekImage.image = UIImage(systemName: "checkmark.circle.fill")
                releaseThisWeekImage.image = nil
                releaseNextWeekImage.image = nil
                releaseThisMonthImage.image = nil}
        case 3:
            Constants.printToConsole("Tag 3")
            if let _ = releaseNextWeekImage.image{
                releaseNextWeekImage.image = nil
                selectedTag = 0
            }else{
                releaseNextWeekImage.image = UIImage(systemName: "checkmark.circle.fill")
                releaseThisWeekImage.image = nil
                releaseLastWeekImage.image = nil
                releaseThisMonthImage.image = nil
            }
        case 4:
            Constants.printToConsole("Tag 4")
            if let _ = releaseThisMonthImage.image{
                releaseThisMonthImage.image = nil
                selectedTag = 0
            }else{
                releaseThisMonthImage.image = UIImage(systemName: "checkmark.circle.fill")
                releaseThisWeekImage.image = nil
                releaseLastWeekImage.image = nil
                releaseNextWeekImage.image = nil
            }
        default:
            Constants.printToConsole("Case not handled")
            selectedTag = 0
        }
        filterView.isHidden = true
    }
    
    //MARK: User Defined functions
    func setUI(){
        filterButton.layer.cornerRadius = 5
        filterView.layer.cornerRadius = 5
        filterView.layer.borderWidth = 1
        filterView.layer.borderColor = UIColor.lightGray.cgColor
        filterView.backgroundColor = UIColor.white
        filterView.isHidden = true
        releaseThisWeekImage.image = nil
        releaseLastWeekImage.image = nil
        releaseNextWeekImage.image = nil
        releaseThisMonthImage.image = nil
        
    }
    func initViews(){
        self.view.endEditing(true)
        activityIndicatorView.isHidden = true
        paginationIndicator.isHidden = true
        comics.removeAll()
    }
    
    func setDelegates(){
        comicsCollectionView.delegate = self
        comicsCollectionView.dataSource = self
        
        
        viewModel.$comics.sink { [weak self] model in
            guard let weakSelf = self else {return}
            if let model = model{
                weakSelf.isLoading = false
                weakSelf.activityIndicatorView.isHidden = true
                weakSelf.comics.append(contentsOf:model.data?.results ?? [])

            }else{
                weakSelf.comics.removeAll()
            }
        }.store(in: &cancellabels)
        
        $selectedTag.sink { [weak self] tag in
            guard let weakSelf = self else {return}
            let firstDayOfWeek = Utils.getFirstDayOfWeek() ?? Date()
            let currentDate = Date().formatDate(format: "YYYY-MM-dd")
            
            switch tag{
            case 1:
                weakSelf.filterDates = "\(firstDayOfWeek.formatDate(format: "YYYY-MM-dd")),\(currentDate)"
            case 2:
                let prevWeekDates = Utils.getPreviousWeekDates()
                if let startDate = prevWeekDates?.startDate.formatDate(format: "YYYY-MM-dd"),
                   let endDate = prevWeekDates?.endDate.formatDate(format: "YYYY-MM-dd"){
                    weakSelf.filterDates = "\(startDate),\(endDate)"
                }
            case 3:
                let nextWeekDates = Utils.getNextWeekDates()
                if let startDate = nextWeekDates?.startDate.formatDate(format: "YYYY-MM-dd"),
                   let endDate = nextWeekDates?.endDate.formatDate(format: "YYYY-MM-dd"){
                    weakSelf.filterDates = "\(startDate),\(endDate)"
                }
            case 4:
                if let startDate = Utils.getStartOfMonth(){
                    weakSelf.filterDates = "\(startDate),\(currentDate)"
                }
            default:
                Constants.printToConsole("Not Handled")
            }
            weakSelf.activityIndicatorView.isHidden = false
            weakSelf.comics.removeAll()
            weakSelf.fetchComics(dates: weakSelf.filterDates)
        }.store(in: &cancellabels)
    }
    
    func fetchComics(dates:String){
        viewModel.getComics(limit: limit, offset: String(offset),dates:dates)
    }
}

extension ComicsViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ComicCollectionCell", for: indexPath) as? CharacterCollectionCell
        
        if let cell = cell{
            cell.name.text = comics[indexPath.row].title
            if let path = comics[indexPath.row].thumbnail?.path,let type = comics[indexPath.row].thumbnail?.thumbnailExtension{
                cell.image.sd_setImage(with: URL(string:"\(path).\(type)"))
            }
        }
        return cell ?? UICollectionViewCell()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
        + flowLayout.sectionInset.right
        + (flowLayout.minimumInteritemSpacing * CGFloat(3))
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(3))
        return CGSize(width: size, height: 170)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.bounds.size.height){
            if !isLoading{
                isLoading = true
                offset += 20
                paginationIndicator.isHidden = false
                fetchComics(dates: filterDates)
            }
        }
       
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        filterView.isHidden = true
        self.view.endEditing(true)
    }
}
