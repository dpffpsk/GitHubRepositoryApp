//
//  RepositoryListViewController.swift
//  GitHubRepositoryApp
//
//  Created by wons on 2023/01/18.
//

import UIKit
import RxSwift
import RxCocoa

class RepositoryListViewController: UITableViewController {
    
    private let organization = "Apple" // Github user
    private let repositories = BehaviorSubject<[Repository]>(value: [])
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = organization + " Repositories"
        
        // 당겨서 새로고침
        self.refreshControl = UIRefreshControl()
        let refreshControl = self.refreshControl!
        refreshControl.tintColor = .darkGray
        refreshControl.attributedTitle = NSAttributedString(string: "당겨서 새로고침")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        tableView.register(RepositoryListCell.self, forCellReuseIdentifier: "RepositoryListCell")
        tableView.rowHeight = 140
    }
    
    @objc func refresh(){
        // API network 통신
        DispatchQueue.global(qos: .background).async {[weak self] in
            guard let self = self else { return }
            self.fetchRepositories(of: self.organization)
        }
    }
    
    func fetchRepositories(of organization: String) {
        Observable.from([organization]) // from : 오직 array 형태의 element만 받음
            .map { organization -> URL in
                return URL(string: "https://api.github.com/orgs/\(organization)/repos")!
                // https://api.github.com/orgs/Apple/repos
            }
            .map { url -> URLRequest in
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                return request
                // https://api.github.com/orgs/Apple/repos
            }
            .flatMap { request -> Observable<(response: HTTPURLResponse, data: Data)> in
                return URLSession.shared.rx.response(request: request)
                // flatMap은 블록 내에서 Observable을 리턴해야하므로, API를 사용할때 응답값이 Observable일때 flatMap사용
                // RxSwift.(unknown context at $1013cae18).AnonymousObservable<(response: __C.NSHTTPURLResponse, data: Foundation.Data)>
            }
            .filter { response, _ in // filter : Bool 데이터 타입의 파라미터(Bool값을 리턴하는 클로저)에 따라 true일 이벤트 방출
                return 200..<300 ~= response.statusCode
                // true
            }
            .map { _, data -> [[String: Any]] in
                guard let json = try? JSONSerialization.jsonObject(with: data, options: []),
                      let result = json as? [[String: Any]] else {
                    return []
                }
                return result
                // [["url": https://api....
            }
            .filter { objects in
                return objects.count > 0
                // true
            }
            .map { objects in
                // compactMap : map 기능 + 옵셔널 바인딩
                return objects.compactMap { dic -> Repository? in
                    guard let id = dic["id"] as? Int,
                          let name = dic["name"] as? String,
                          let description = dic["description"] as? String,
                          let stargazersCount = dic["stargazers_count"] as? Int,
                          let language = dic["language"] as? String else {
                        return nil
                    }
                    return Repository(id: id, name: name, description: description, stargazersCount: stargazersCount, language: language)
                }
            }
            .subscribe(onNext: {[weak self] newRepositories in
                self?.repositories.onNext(newRepositories)
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.refreshControl?.endRefreshing()
                }
            })
            .disposed(by: disposeBag)
    }
    

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        do {
            return try repositories.value().count
        } catch {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RepositoryListCell", for: indexPath) as? RepositoryListCell else { return UITableViewCell() }

        var currentRepo: Repository? {
            do {
                return try repositories.value()[indexPath.row]
            } catch {
                return nil
            }
        }
        
        cell.repository = currentRepo
        
        return cell
    }
}
