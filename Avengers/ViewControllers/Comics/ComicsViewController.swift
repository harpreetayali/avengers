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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegates()
    }
    override func viewWillAppear(_ animated: Bool) {
        initViews()
        activityIndicatorView.isHidden = false
        fetchComics()
    }
    override func viewWillLayoutSubviews() {
        self.comicsCollectionView.reloadData()
    }
    //MARK: User Defined functions
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
    }
    
    func fetchComics(){
        viewModel.getComics(limit: limit, offset: String(offset))
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
        return CGSize(width: size, height: 150)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.bounds.size.height){
            if !isLoading{
                isLoading = true
                offset += 20
                paginationIndicator.isHidden = false
                fetchComics()
            }
        }
       
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}
