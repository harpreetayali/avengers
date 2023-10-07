//
//  CharactersViewController.swift
//  Avengers
//
//  Created by Harpreet Singh on 05/10/23.
//

import UIKit
import Combine
import SDWebImage
import IQKeyboardManagerSwift
class CharactersViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var charactersCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var paginationIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchHistoryTableView: UITableView!
    @IBOutlet weak var notDataFoundLabel: UILabel!
    
    //MARK: Variables
    private let viewModel = CharactersViewModel()
    private var cancellabels = Set<AnyCancellable>()
    private var characters:[Result] = []{
        didSet{
            self.paginationIndicator.isHidden = true
            self.charactersCollectionView.reloadData()
            self.charactersCollectionView.layoutIfNeeded()
        }
    }
    private var limit = "20"
    private var offset = 0
    private var isLoading:Bool = false
    var searchHistory:[String]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDelegates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initViews()
    }
    override func viewWillLayoutSubviews() {
        self.charactersCollectionView.reloadData()
    }
    //MARK: User Defined functions
    func initViews(){
        searchHistory = UserDefaults.standard.stringArray(forKey: Constants.SEARCH_HISTORY)
        self.view.endEditing(true)
        notDataFoundLabel.isHidden = true
        activityIndicator.isHidden = true
        paginationIndicator.isHidden = true
        characters.removeAll()
        searchBar.searchTextField.text = ""
        searchHistoryTableView.isHidden = true
    }
    
    func setDelegates(){
        charactersCollectionView.delegate = self
        charactersCollectionView.dataSource = self
        searchBar.delegate = self
        
        searchHistoryTableView.delegate = self
        searchHistoryTableView.dataSource = self
    }
    func fetchCharacters(query:String = ""){
        viewModel.getCharacters(limit: limit, offset: String(offset),query: query).sink {[weak self] completion in
            guard let weakSelf = self else {return}
            if weakSelf.offset == 0{
                switch completion{
                case .failure(let error):
                    weakSelf.notDataFoundLabel.text = error.localizedDescription
                default:
                    Constants.printToConsole(completion)
                }
                weakSelf.characters.removeAll()
                weakSelf.notDataFoundLabel.isHidden = false
                weakSelf.activityIndicator.isHidden = true
                weakSelf.searchHistoryTableView.isHidden = true
                weakSelf.view.endEditing(true)
            }else {
                weakSelf.activityIndicator.isHidden = true
            }
        } receiveValue: { [weak self] model in
            guard let weakSelf = self else {return}
            if let query = weakSelf.searchBar.searchTextField.text,!query.isEmpty,
               let result = model.data?.results, !result.isEmpty{
                weakSelf.notDataFoundLabel.isHidden = true
                weakSelf.isLoading = false
                weakSelf.activityIndicator.isHidden = true
                weakSelf.characters.append(contentsOf:result)
                weakSelf.saveHistory()
            }
        }.store(in: &cancellabels)

    }
    
    func saveHistory(){
        searchHistoryTableView.isHidden = true
        let query = searchBar.searchTextField.text ?? ""
        if let searchHistory = searchHistory{
            var newHistory = searchHistory
            if !newHistory.contains(query){
                newHistory.append(query)
                self.searchHistory = newHistory
                searchHistoryTableView.reloadData()
                UserDefaults.standard.setValue(newHistory, forKey: Constants.SEARCH_HISTORY)
            }
        }else{
            let history = [query]
            UserDefaults.standard.setValue(history, forKey: Constants.SEARCH_HISTORY)
        }
    }
    
    
}
//MARK: Characters Collection View
extension CharactersViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return characters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CharacterCollectionCell", for: indexPath) as? CharacterCollectionCell
        if let cell = cell{
            cell.name.text = characters[indexPath.row].name
            if let path = characters[indexPath.row].thumbnail?.path,let type = characters[indexPath.row].thumbnail?.thumbnailExtension{
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
                fetchCharacters()
            }
        }
       
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
}

//MARK: Search Bar
extension CharactersViewController:UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty{
            initViews()
            
        }else{
            activityIndicator.isHidden = false
            characters.removeAll()
            fetchCharacters(query: searchText)
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchHistoryTableView.isHidden = false
    }
}

//MARK: History Table View
extension CharactersViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchHistory?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if #available(iOS 14.0, *) {
            var content = cell?.defaultContentConfiguration()
            content?.text = searchHistory?[indexPath.row]
            cell?.contentConfiguration = content
        } else {
            cell?.textLabel?.text = searchHistory?[indexPath.row]
        }
        
        return cell ?? UITableViewCell()
    }
}

