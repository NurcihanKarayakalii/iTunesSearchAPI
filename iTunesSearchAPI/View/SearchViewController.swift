//
//  ViewController.swift
//  SearchAPI
//
//  Created by Nurcihan Karayakalı on 5.01.2022.
//

import UIKit

class SearchViewController: UIViewController {

    // MARK: - Properties
    
    
    @IBOutlet weak var searchBarView: UISearchBar!
    
    private var contentListViewModel : ContentListViewModel = ContentListViewModel()

        
    private var collectionView : UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let spacing: CGFloat = 10
        let numOfColumns: CGFloat = 4
        
        let itemSize: CGFloat = (UIScreen.main.bounds.width - (spacing * (numOfColumns+1))) / numOfColumns
        layout.itemSize = CGSize(width: itemSize, height: itemSize + 50)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        
        
        let collectionView = UICollectionView(frame: CGRect.zero,
                                              collectionViewLayout: layout)
        collectionView.backgroundColor = GlobalConstants.COLOR_LIGHT_GRAY
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.minimumLineSpacing = 10
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(ModelCollectionCell.self, forCellWithReuseIdentifier: GlobalConstants.cellReuseIdentifier)
        collectionView.register(HeaderReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: GlobalConstants.headerViewReuseIdentifier)
        
        return collectionView
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "iTunes Search API"
        searchBarView.placeholder = "Search"
        searchBarView.sizeToFit()
        view.addSubview(collectionView)
        contentListViewModel.delegate = self

        setupDelegates()
        setupCollectionViewConstraints()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = GlobalConstants.COLOR_NAV_COLOR
            let navigationFont = UIFont.systemFont(ofSize: 18.0, weight: .medium)
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white ,.font: navigationFont]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            navigationController?.navigationBar.tintColor = .white
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
    }
    
    //MARK Private Methods
    private func setupDelegates() {
        collectionView.delegate = self
        collectionView.dataSource = self
        searchBarView.delegate = self
    }
    
    private func setupCollectionViewConstraints() {
        self.view.addConstraints([collectionView.topAnchor.constraint(equalTo: self.searchBarView.bottomAnchor),
                                  collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
                                  collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                                  collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)])
        
        
    }
    
   private func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            tap.cancelsTouchesInView = false
            view?.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        searchBarView.endEditing(true)
           
    }
    private func clearContents() {
        contentListViewModel.clearAllValues()
        collectionView.reloadData()
    }
  
    //MARK Get Data With Search Text
    private func searchTextCatch(text: String) {
        contentListViewModel.getDataFromService(text: text);
    
    }
}
    
extension SearchViewController :UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 0{
            guard searchText.count > 1 else {  return }
            clearContents()
            self.searchTextCatch(text: searchText)
        }
        else{
            clearContents()
        }
        
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
    }
        
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.endEditing(true)
    }
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let components = text.components(separatedBy: GlobalConstants.allowedCharacters)
        let filtered = components.joined(separator: "")
        if text == filtered {
            return true
        } else {
            return false
        }
    }
  
}

extension SearchViewController:UIScrollViewDelegate{
   
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBarView.endEditing(true)
        let contentOffsetY = scrollView.contentOffset.y
        if contentOffsetY >=  (scrollView.contentSize.height - scrollView.frame.size.height) - 20 {
            guard !contentListViewModel.isLoadingValue() else { return }
            if searchBarView.searchTextField.text != nil{
                contentListViewModel.scrollViewDidScrollBottom(text: searchBarView.searchTextField.text!)
            }
        }
        
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
    }
}

extension SearchViewController: UICollectionViewDataSource,UICollectionViewDelegate ,UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return contentListViewModel.numberOfSections()
    }

   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contentListViewModel.numberOfRowsInSections(section)
    }
       
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
           return CGSize(width: collectionView.frame.width, height: 30.0)
    }
   
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GlobalConstants.cellReuseIdentifier, for: indexPath) as? ModelCollectionCell{
            let content = contentListViewModel.contentAtSectionAndIndex(indexPath.section, indexPath.row)
            cell.setModelValues(with: content)
            return cell
            
        } else {
            return UICollectionViewCell()
        }
        
    }
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let content = contentListViewModel.collectionCellSelected(indexPath.section, indexPath.row)
        let detailVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController
        detailVC?.detailViewModel = content
        self.navigationController?.pushViewController(detailVC!, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let reusableView : UICollectionReusableView! = nil
        
        if kind == UICollectionView.elementKindSectionHeader {
            if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: GlobalConstants.headerViewReuseIdentifier, for: indexPath) as? HeaderReusableView
            {
                
                let section = contentListViewModel.getHeaderViewModel(indexPath.section)
                sectionHeader.setTitleValue(with: section)
                return sectionHeader
            }
            else{
                return reusableView
            }
        }
        return reusableView
    }
    
}

extension SearchViewController: ContentListViewModelDelegate {
    func dataLoadedFromService() {
        DispatchQueue.main.async {
        self.collectionView.reloadData()
        }
        
    }
}
