//
//  UGCPersonalUGCViewController.swift
//  TT
//
//  Created by LiHong on 2018/12/6.
//  Copyright © 2018 yiyou. All rights reserved.
//

import Foundation

class UGCPersonalUGCViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    fileprivate let tableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.plain)
    
    fileprivate var cellLayoutList = [UGCPostCellLayout]()
    fileprivate var postList = [TTUGCPostInfo]()
    
    fileprivate var emptyView = UIView()
    
    fileprivate var emptyCircleView = UIView()
    
    fileprivate var followButton: UIButton!
    
    fileprivate var isMyUGC: Bool = false
    
    fileprivate var following: Bool = false
    
    fileprivate var hasGameCircle: Bool = false
    
    fileprivate var reachEnd : Bool = false
    
    fileprivate var lastOneIndex : Int = -1
    
    fileprivate var loadMore: NSObject?
    
    fileprivate var lastIndexPath = IndexPath(row: 0, section: 0)
    
    fileprivate var showCircle: Bool = false
    
    fileprivate var showWindow: Bool = false
    
    fileprivate var browserPostMap = [String: String]()
    
    fileprivate let kFollowerShowWindowKey: String = "FollowerShowWindow"
    
    fileprivate let kFollowerCurrentDateKey: String = "FollowerCurrentDate"
    
    fileprivate let followerCount = 20
    
    @objc var contact: TTContact?
    
    deinit {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = UIColor.globalBackground()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        self.tableView.register(UGCPostCell.self, forCellReuseIdentifier: "UGCPostCell")
        self.tableView.enablePullToLoadMore()
        self.tableView.setPullToLoadMoreAction { [weak self] (tableView) in
            guard let sself = self else { return }
            sself.loadUGCData()
        }
        self.title = "个人动态"
        self.view.backgroundColor = UIColor.globalBackground()//UIColor.init(red: 242, green: 242, blue: 242, alpha: 1)
        
        let authService: AuthService = GetService()
        if let contactUid = self.contact?.uid {
            if authService.myUid() == contactUid {
                self.isMyUGC = true
            }
        }
        
        if self.isMyUGC {
            self.following = true
        } else {
            let ugcService: UGCService = GetService()
            
            if ugcService.isFollowedUid(self.contact?.uid ?? 0) {
                self.following = true
            }
            
        }
        if self.following == false  {
            self.setUpRightItem()
        }
        self.requestUserGameCircleInfo()
        
        // 监听通知
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (self.cellLayoutList.count == 0){
            self.loadMore = nil
            
        }
        if (!self.reachEnd){
            self.tableView.enablePullToLoadMore()
        }
    }
    
    func setUpRightItem() {

        let rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: 52, height: 24))
        rightButton.layer.borderColor = UIColor.argb(0x4594FF)?.cgColor
        rightButton.layer.borderWidth = 1
        rightButton.layer.cornerRadius = 12
        rightButton.layer.masksToBounds = true
//        rightButton.setTitle("关注", for: .normal)
//        rightButton.setTitleColor(UIColor.argb(0x4594FF), for: .normal)
//        rightButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
//        rightButton.setTitleColor(UIColor.ttGray3(), for: .disabled)
//        rightButton.setTitle("已关注", for: .disabled)
        rightButton.setImage(UIImage(named: "ic_trend_follow"), for: .normal)
        rightButton.setImage(UIImage(named: "ic_trend_followed"), for: .disabled)
        rightButton.isEnabled = true
        rightButton.addTarget(self, action: #selector(UGCPersonalUGCViewController.followButtonClicked(_:)), for: .touchUpInside)
        let contentView = UIView(frame: CGRect(x: 0, y: 0, width: 52, height: 24))
        contentView.addSubview(rightButton)
        self.followButton = rightButton
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: contentView)
    }
    
    @objc func followButtonClicked(_ button: UIButton){
        self.trackClickEventId(ATTENTION_BUTTON_CLICK, eventExt: "")
        let ugcService: UGCService = GetService()
        ugcService.reqFriendshipOperationFollowUserUid(self.contact?.uid ?? 0, account: self.contact?.account ?? "", alias: self.contact?.accountAlias ?? "",callback: { (error) in
            if error != nil {
                UIUtil.showError(error)
                return
            }
            button.isEnabled = false
            button.backgroundColor = UIColor.ttGray4()
            button.layer.borderWidth = 0
            self.following = true
            UIUtil.showHint("关注成功")
        }, customSource: "", source: FriendshipSource.sourceFeeds)
    }
    
    func setEmptyView() {
        self.emptyView.removeFromSuperview()
        self.emptyView.isHidden = false
        self.tableView.isHidden = true
        self.view.addSubview(self.emptyView)
        self.emptyView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        let emptyImageView = UIImageView.init()
        emptyImageView.image = UIImage(named: "game_icon_blankpage_dynamic")
        self.emptyView.addSubview(emptyImageView)
        emptyImageView.snp.makeConstraints { (make) in
            make.height.equalTo(160)
            make.width.equalTo(160)
            make.centerX.equalTo(self.view.centerX)
            make.top.equalTo(193)
        }
        let emptyLabel = UILabel()
        emptyLabel.text = "介个小宇宙还有待发掘"
        emptyLabel.font = UIFont.systemFont(ofSize: 14);
        emptyLabel.textColor = UIColor.argb(0xABABAB)
        self.emptyView.addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view.centerX)
            make.top.equalTo(emptyImageView.snp.bottom).offset(14)
        }
        if self.isMyUGC {
            emptyLabel.text = "发布第一条动态给懂你的人看吧"
            let emptyButtonView = UIView()
            self.emptyView.addSubview(emptyButtonView)
            emptyButtonView.snp.makeConstraints { (make) in
                make.width.equalTo(120)
                make.height.equalTo(40)
                make.centerX.equalTo(self.view.centerX)
                make.top.equalTo(emptyLabel.snp.bottom).offset(14)
            }
            let layer = CAGradientLayer()
            layer.frame = CGRect(x: 0, y: 0, width: 120, height: 40)
            layer.startPoint = CGPoint(x: 0, y: 0.5)
            layer.endPoint = CGPoint(x: 1, y: 0.5)
            layer.colors = [UIColor.argb(0x4594FF)?.cgColor as Any ,UIColor.argb(0x50DEFF)?.cgColor as Any]
            emptyButtonView.layer.insertSublayer(layer, at: 0)
            emptyButtonView.layer.cornerRadius = 20
            emptyButtonView.layer.masksToBounds = true
            let emptyButtonLabel = UILabel()
            emptyButtonLabel.text = "去发布"
            emptyButtonLabel.textColor = UIColor.argb(0xFFFFFF)
            emptyButtonLabel.font = UIFont.systemFont(ofSize: 15)
            emptyButtonView.addSubview(emptyButtonLabel)
            emptyButtonLabel.snp.makeConstraints { (make) in
                make.top.equalTo(10)
                make.left.equalTo(32)
            }
            let emptyButtonImageView = UIImageView()
            emptyButtonImageView.image = UIImage(named: "ic_blank_page_btn_trend_publish")
            emptyButtonView.addSubview(emptyButtonImageView)
            emptyButtonImageView.snp.makeConstraints { (make) in
                make.top.equalTo(10)
                make.left.equalTo(emptyButtonLabel.snp.right).offset(2)
                make.width.equalTo(18)
                make.height.equalTo(18)
            }
            let tap = UITapGestureRecognizer(target: self, action: #selector(UGCPersonalUGCViewController.emptyButtonViewTap(_:)))
            emptyButtonView.addGestureRecognizer(tap)
            
        }
        let emptyCircle = self.gameCircleCellView()
        self.emptyView.addSubview(emptyCircle)
        let safeHeight = DeviceUtil.getSafeAreaBottomHeight()
        emptyCircle.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-20-safeHeight)
            make.width.equalToSuperview()
            make.height.equalTo(45)
            make.centerX.equalToSuperview()
        }
        if !self.showCircle {
            emptyCircle.isHidden = true
        }
        self.emptyCircleView.removeFromSuperview()
        self.emptyCircleView = emptyCircle
    }
    
    @objc func emptyButtonViewTap(_ recognizer: UIGestureRecognizer) {
        UGCPublishPageUtil.postUGC(selectTopic: nil, subTopic: nil, fromViewController: self)
//        let vc = PublishPageViewController()
//        self.navigationController?.pushViewController(vc, animated: true)
    }

    func loadUGCData() {
        let ugcService: UGCService = GetService()
        ugcService.requestGet(UGCPostListType.userTimeLine, uid: self.contact?.uid ?? 0, account: self.contact?.account ?? "", alias: self.contact?.accountAlias ?? "", count: 10, loadMore: self.loadMore) {[weak self] (list, userinfoList ,loadMore, error) in
            guard let sself = self else { return }
            sself.tableView.finishPullToLoadMore()
            if error == nil {
                if (sself.loadMore == nil) {
                    sself.cellLayoutList.removeAll()
                }
                sself.loadMore = loadMore
                if let listList = list {
                    
                    
                    for postInfo in listList {
                        sself.cellLayoutList.append(UGCPostCellLayout(postInfo: postInfo, isDetail: false, isFollowed: true, isShowRoom: false, isDelete: false, isRemove: false, isFavourite: false))
                        sself.postList.append(postInfo)
                    }
                    if (sself.cellLayoutList.count == 0) {
                        sself.tableView.isHidden = true
                        sself.emptyView.isHidden = false
                    }
                    else {
                        sself.tableView.isHidden = false
                        sself.emptyView.isHidden = true
                    }
                    sself.reachEnd = loadMore == nil || listList.count < 10
                    if (sself.reachEnd){
                        sself.lastOneIndex = sself.postList.count
                        sself.tableView.disablePullToLoadMore()
                    }
                    sself.tableView.reloadData()
//                    sself.tableView.scrollToRow(at: sself.lastIndexPath, at: .middle, animated: true)

                }
                if sself.cellLayoutList.count == 0 {// || list == nil {
                    sself.setEmptyView()
                }
            } else {
                sself.setEmptyView()
                UIUtil.showError(error)
            }
        }
    }
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if (reachEnd && hasGameCircle){
            return (self.cellLayoutList.count + 2)
        }
        else if (reachEnd){
            return (self.cellLayoutList.count + 1)
        }
        return self.cellLayoutList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (reachEnd){
            if (self.cellLayoutList.count == indexPath.section){
                if (hasGameCircle){
                    let cell:UITableViewCell = UITableViewCell()
                    let subView:UIView = self.gameCircleCellView()
                    cell.frame = subView.frame
                    cell.contentView.addSubview(subView)
                    cell.backgroundColor = UIColor.clear
                    return cell
                }
                else {
                    let cell:UITableViewCell = UITableViewCell()
                    let subView:UIView = self.bottomView()
                    cell.contentView.addSubview(subView)
                    cell.frame = subView.frame
                    cell.backgroundColor = UIColor.clear
                    return cell
                }
            }
            else if (self.cellLayoutList.count + 1 == indexPath.section){
                let cell:UITableViewCell = UITableViewCell()
                let subView:UIView = self.bottomView()
                cell.frame = subView.frame
                cell.contentView.addSubview(subView)
                cell.backgroundColor = UIColor.clear
                return cell
            }
        }
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "UGCPostCell") as! UGCPostCell
        let layout = self.cellLayoutList[indexPath.section]
        cell.setData(layout, tableView: tableView)
        cell.onDeletePost = {[weak self](deleteIndexPath) -> Void in
            if let sself = self {
                sself.cellLayoutList.remove(at: deleteIndexPath.section)
                sself.tableView.beginUpdates()
                sself.tableView.deleteSections([deleteIndexPath.section], with: UITableViewRowAnimation.automatic)
                sself.tableView.endUpdates()
                if (sself.cellLayoutList.count == 0){
                    sself.loadUGCData()
//                    sself.tableView.isHidden = true
//                    sself.emptyView.isHidden = false
                }
            }
        }
        
        //统计，帖子浏览
        let service : CustomStatisticsService_V2 = GetService()
        let paramsExt = ["postId":"\(layout.postInfo.postId)",
                         "postUid":"\(layout.postInfo.postOwner.uid)"]
        service.trackPageEventPageClass(self.tag, pageExt: "", event: .exposure, matchKey: "", paramsExt: paramsExt)
        
        if !self.following {
            DispatchQueue.global().async {
                let service: UGCService = GetService()
                
                guard let userInfo = service.myUgcUserInfo, userInfo.followingCount >= 0 else {
                    return
                }
//                触发条件：
//                1、关注数<20人，单次在个人流中浏览的动态条数>10条时弹窗提示关注用户；
//                2、关注数>20人，单次在个人流中浏览的动态条数>20条时弹窗提示关注用户；
//                备注：
//                1、该弹窗对同一用户每天只会弹一次
//                2、浏览指的是滑过该动态就算，不需要点击进入详情页；
                if service.myUgcUserInfo.followingCount < self.followerCount {
                    if self.browserPostMap.count > 10 && self.following == false {
                        // 弹窗
                        self.showFollowWindow(layout.postInfo)
                    }
                } else if service.myUgcUserInfo.followingCount >= self.followerCount {
                    if self.browserPostMap.count > 20 && self.following == false {
                        // 弹窗
                        self.showFollowWindow(layout.postInfo)
                    }
                }
                self.browserPostMap[layout.postInfo.postId] = layout.postInfo.postId
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (reachEnd){
            if (self.cellLayoutList.count == indexPath.section){
                if (hasGameCircle){
                    return 45
                }
                else {
                    return 65
                }
            }
            else if (self.cellLayoutList.count + 1 == indexPath.section){
                return 65
            }
        }
        return self.cellLayoutList[indexPath.section].height
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let viewSection = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: self.tableView(tableView, heightForHeaderInSection: section)))
        viewSection.backgroundColor = UIColor.clear
        return viewSection
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.lastIndexPath = indexPath
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    fileprivate func showFollowWindow(_ postInfo: TTUGCPostInfo) {
        DispatchQueue.main.async {
            if self.showWindow == true {
                return
            }
            let uid = postInfo.postOwner.uid
            let userDefaults = UserDefaults.standard
            let currentDate = userDefaults.object(forKey: self.kFollowerCurrentDateKey + "\(uid)") as? Date
            if currentDate != nil {
                let isToday = NSCalendar.current.isDateInToday(currentDate!)
                if !isToday {
                    self.showFollowerWindow(postInfo)
                } else {
                    if (userDefaults.bool(forKey: self.kFollowerShowWindowKey + "\(uid)")) {
                        self.showWindow = true
                    }
                }
            } else {
                self.showFollowerWindow(postInfo)
            }
            
        }
    }
    
    fileprivate func showFollowerWindow(_ postInfo: TTUGCPostInfo) {
        
        self.showWindow = true
        
//        let now = Date()
//        let zone: TimeZone = TimeZone.current
//        let interval = zone.secondsFromGMT(for: now)
//        let localeDate = now.addingTimeInterval(TimeInterval(interval))
        
//        let fmt = DateFormatter()
//        fmt.dateStyle = .medium
//        fmt.timeStyle = .none
//        fmt.locale = NSLocale.current
//        let dateString = fmt.string(from: localeDate)
        
        let uid = postInfo.postOwner.uid
        let userDefaults = UserDefaults.standard
        userDefaults.set(Date(), forKey: self.kFollowerCurrentDateKey + "\(uid)")
        userDefaults.synchronize()
        
        UserDefaults.standard.set(true, forKey: self.kFollowerShowWindowKey + "\(uid)")
        UserDefaults.standard.synchronize()
        
        let alertView: UGCUserFollowActionView = UGCUserFollowActionView(postInfo: postInfo)
        alertView.cancelBlock = { () in
            
        }
        alertView.completeBlock = { [weak self] () in
            self?.followButtonClicked((self?.followButton)!)
        }
        alertView.showInView(self.navigationController?.view)
    }
    
    func requestUserGameCircleInfo(){
        let circleService:CircleService = GetService()
        let success = {[weak self](topicList: [Any]!, pageId: UInt32) -> Void in
            if let sself = self {
                sself.showCircle = topicList.count != 0
                if topicList.count == 0{
                    sself.hasGameCircle = false
                    sself.emptyCircleView.isHidden = true
                }
                else {
                    sself.hasGameCircle = true
                    sself.emptyCircleView.isHidden = false
                }
                sself.loadUGCData()
            }
        }
        let failure = {[weak self](error: Error) -> Void in
            if let sself = self {
                sself.hasGameCircle = false
            }
            UIUtil.showError(error)
        }
        circleService.requestTopicList(forUser: self.contact?.uid ?? 0, startCircleId: 0, startTopicId: 0, topicCount: 30, success: success, failure: failure)
    }
    
    func bottomView()->UIView {
        let view:UIView = UIView()
        view.backgroundColor = UIColor.clear
        let label:UILabel = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "哎呀，人家是有底线的"
        label.textColor = UIColor.ttGray3()
        view.addSubview(label)
        label.textAlignment = NSTextAlignment.center
        label.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(17)
            make.top.equalTo(8)
        }
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 77)
        return view
    }
    
    func gameCircleCellView()->UIView{
        let viewSection = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 45))
        viewSection.backgroundColor = UIColor.clear
        let fakeCell = UIControl()
        let label = UILabel()
        let arrow = UIImageView(image: UIImage(named: "ic_game_group_go"))
        fakeCell.addSubview(label)
        fakeCell.addSubview(arrow)
        fakeCell.backgroundColor = UIColor.white
        viewSection.addSubview(fakeCell)
        fakeCell.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        label.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.equalTo(80)
            make.height.equalTo(12)
        }
        label.text = self.isMyUGC ? "我的游戏圈" : "Ta的游戏圈"
        label.font = UIFont.systemFont(ofSize: 15)
        arrow.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.width.equalTo(13)
            make.height.equalTo(13)
        }
        fakeCell.layer.cornerRadius = 12
        fakeCell.layer.masksToBounds = true
        fakeCell.addTarget(self, action: #selector(jumpToGameCircle), for: UIControlEvents.touchUpInside)
        return viewSection
    }
    
    @objc func jumpToGameCircle(){
        let vc:CircleTopicListViewController = CircleTopicListViewController(type: CircleTopicListViewType.circleTopicListViewTypeUser)
        let authService:AuthService = GetService()
        if (self.isMyUGC){
            vc.title = "我的游戏圈"
            vc.userUid = authService.myUid()
        }
        else {
            vc.title = "TA的游戏圈"
            vc.userUid = self.contact?.uid ?? 0
        }
        if let navi = self.navigationController{
            objc_sync_enter(navi.viewControllers)
            navi.pushViewController(vc, animated: true)
            objc_sync_exit(navi.viewControllers)
        }
    }
}
