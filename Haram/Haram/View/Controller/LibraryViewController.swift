//
//  LibraryViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/05/18.
//

import UIKit

import SnapKit
import Then

final class LibraryViewController: BaseViewController {
  
  private let searchController = UISearchController(searchResultsController: LibraryResultsViewController()).then {
    $0.searchBar.placeholder = "도서검색하기"
  }
  
  override func setupStyles() {
    super.setupStyles()
    navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(didTappedBackButton))
    title = "도서검색"
    navigationItem.searchController = searchController
  }
  
  @objc private func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
}
