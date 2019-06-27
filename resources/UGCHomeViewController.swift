//
//  UGCHomeViewController.swift
//  TT
//
//  Created by wangyilong on 2018/11/5.
//  Copyright © 2018 yiyou. All rights reserved.
//

import Foundation

let UGCHomePublishBeforeEveryVersionKey:String = "UGCHomePublishBeforeEveryVersion"

class UGCHomeViewController: BaseViewController, UIScrollViewDelegate {
    
    @objc func changeSelectIndex(_ i :NSInteger){
        self.currentSelectIndex = i
        self.segmentedControl.selectedSegmentIndex = i
    }
    
    var currentSelectIndex: Int! = 1 {
        didSet{
            if currentSelectIndex == 0 {
                self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)

                self.recommendViewController.viewWillDisappear(true)
                self.recommendViewController.viewDidDisappear(true)
                self.recommendViewController.needStatistics = false
                
                self.subscribeViewController.showLineFlag = nil
                self.subscribeViewController.needStatistics = self.didAppear
                self.subscribeViewController.viewWillAppear(true)
                self.subscribeViewController.viewDidAppear(true)
                if(self.subscribeViewController.isShowRecommendV){
                    self.publishButton?.isHidden = true
                }else if(!self.subscribeViewController.isShowRecommendV){
                    self.publishButton?.isHidden = false
                }
                
                
                if self.followLabelRedPoint?.isHidden == false {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
                        self.subscribeViewController.refreshIfNeed(false)
                    }
                }
            } else {
                self.publishButton?.isHidden = false
                self.scrollView.setContentOffset(CGPoint(x: screenWidth, y: 0), animated: true)
                self.recommendViewController.showLineFlag = nil
                self.recommendViewController.needStatistics = self.didAppear
                self.recommendViewController.viewWillAppear(true)
                self.recommendViewController.viewDidAppear(true)
                
                self.subscribeViewController.viewWillDisappear(true)
                self.subscribeViewController.viewDidDisappear(true)
                self.subscribeViewController.needStatistics = false
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
                    self.recommendViewController.refreshIfNeed(false)
                }
            }
        }
    }
    
    fileprivate let segmentedControl: TTSegmentedControl! = TTSegmentedControl(frame: CGRect(x: 0, y: 0, width: 124, height: 44), items: ["关注","推荐"])
    fileprivate let scrollView = UIScrollView()
    
    fileprivate let subscribeViewController = UGCSubscribeViewController()
    fileprivate let recommendViewController = UGCRecommendViewController()
    fileprivate var publishButton : UIButton?
//    fileprivate var publishedBefore:Bool = false
    fileprivate var unreadView: JSBadgeView?
    fileprivate var followLabelRedPoint: UIView?

    fileprivate var didFirstSelectedSegment: Bool = false
    fileprivate var didAppear: Bool = false
    fileprivate let EverPublishKey : String = "UGCEverPublish"
    
    // MARK: - View Action
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            self.updateTabBarBadgeValue()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let service: UGCService = GetService()
        service.reqGetMyUserUGCInfoCallBack { (_, error) in
            
        } // 把自己信息保存到内存
        
        self.automaticallyAdjustsScrollViewInsets = false
    
        // TTSegmentedControl
        self.segmentedControl.titleSelectColor = UIColor.ttGray1()
        self.segmentedControl.titleDefaultColor = UIColor.ttGray2()
        self.segmentedControl.addTarget(self, action: #selector(UGCHomeViewController.onSegmentedControlChange(_:)), forControlEvent: UIControlEvents.valueChanged)
        self.segmentedControl.addTarget(self, action: #selector(UGCHomeViewController.onSegmentedControlDoubleTap(_:)), forControlEvent: UIControlEvents.allTouchEvents)
        let headerContentView = UIView()
        headerContentView.frame = CGRect(x: 0, y: 0, width: 124, height: 44)
        headerContentView.addSubview(self.segmentedControl)
        self.navigationController?.navigationBar.topItem?.titleView = headerContentView
        
        if let followLabel = self.segmentedControl.titleLabel(at: 0) {
            self.followLabelRedPoint = UIView()
            self.followLabelRedPoint!.frame = CGRect(x: 33, y: 0, width: 8, height: 8)
            self.followLabelRedPoint!.backgroundColor = UIColor(hex: 0xFF6365FF)
            self.followLabelRedPoint!.layer.cornerRadius = 4
            self.followLabelRedPoint!.layer.masksToBounds = true
            self.followLabelRedPoint!.isHidden = true
            followLabel.addSubview(self.followLabelRedPoint!)
        }

        // ScrollView
        self.scrollView.isPagingEnabled = true
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.contentSize = CGSize(width: screenWidth * 2, height: 0)
        self.scrollView.delegate = self
        self.scrollView.isDirectionalLockEnabled = true
        self.scrollView.backgroundColor = UIColor.globalBackground()
        self.scrollView.bounces = false
        self.view.addSubview(self.scrollView)
        self.scrollView.snp.makeConstraints { (make) in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.top.equalTo(topLayoutGuide.snp.bottom)
            make.bottom.equalTo(bottomLayoutGuide.snp.top)
        }
        
        // ViewController
        self.addChildViewController(self.subscribeViewController)
        self.addChildViewController(self.recommendViewController)
        self.scrollView.addSubview(self.subscribeViewController.view)
        self.scrollView.addSubview(self.recommendViewController.view)
        
        self.subscribeViewController.view.snp.makeConstraints { (make) in
            make.top.equalTo(self.scrollView)
            make.left.equalTo(self.scrollView)
            make.width.equalTo(screenWidth)
            make.height.equalTo(self.scrollView.snp.height)
        }
        self.subscribeViewController.onHideRedPoint = {[weak self] in
            if let sself = self {
                let service:UGCService = GetService()
                service.notifiesUpdate = false
                sself.followLabelRedPoint?.isHidden = true
                sself.updateTabBarBadgeValue()
            }
        }
        
        self.recommendViewController.view.snp.makeConstraints { (make) in
            make.top.equalTo(self.scrollView)
            make.left.equalTo(self.subscribeViewController.view.snp.right)
            make.width.equalTo(screenWidth)
            make.height.equalTo(self.scrollView.snp.height)
        }
        
        self.subscribeViewController.didMove(toParentViewController: self)
        self.recommendViewController.didMove(toParentViewController: self)
        self.initialNavigation()
        self.initialPublishButton()
        
        ObserveService(self, withClientProtocol: UGCServiceClient.self)
        
        self.updateTabBarBadgeValue()
        
        if !self.didFirstSelectedSegment {
            let temp = self.currentSelectIndex
            self.currentSelectIndex = temp
            self.segmentedControl.selectedSegmentIndex = temp ?? 1
        }
//        self.publishedBefore = UserDefaults.standard.bool(forKey: UGCHomePublishBeforeEveryVersionKey)
        
        // 监听通知
//        NotificationCenter.default.addObserver(self, selector: #selector(beginSendingPost(_:)), name: NSNotification.Name.init("UGCPostSendingNSNotification"), object: nil)
    }
    
    deinit {
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.init("UGCPostSendingNSNotification"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.subscribeViewController.needStatistics = (self.currentSelectIndex == 0)
        self.recommendViewController.needStatistics = (self.currentSelectIndex == 1)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.didAppear = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.didAppear = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    // MARK: - Unread
    
    fileprivate func initialNavigation()  {
        let button = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 24, height: 44))
        button.backgroundColor = UIColor.init(white: 1, alpha: 0.01)
        let view = UIView.init(frame: CGRect.init(x: 0, y: 13, width: 21, height: 21))
        view.isUserInteractionEnabled = false;
        button.addSubview(view)
        button.setImage(UIImage.init(named: "ic_all_notice"), for: UIControlState.normal)
        self.unreadView = JSBadgeView.init(parentView: view, alignment: JSBadgeViewAlignment.topRight)
        button.addTarget(self, action: #selector(rightItemClicked), for: UIControlEvents.touchUpInside)
        self.unreadView?.badgeBackgroundColor = UIColor.ttRedMain()
        self.unreadView?.badgeText = "0"
        
        let rightitem = UIBarButtonItem.init(customView: button);
        self.navigationItem.rightBarButtonItem = rightitem
    }
    
    @objc fileprivate func rightItemClicked() {
        let controller = UGCMessagesController.init()
        if !(self.navigationController?.viewControllers.last?.isKind(of: UGCMessagesController.self) ?? false) {
            self.navigationController?.pushViewController(controller, animated: true)
        }
        
        let service:UGCService = GetService()
        service.clearNotifyCount()
        
        self.updateTabBarBadgeValue()
    }
    
    // MARK: - Action
    
    @objc fileprivate func onSegmentedControlChange(_ sender: TTSegmentedControl) {
        self.currentSelectIndex = sender.selectedSegmentIndex
    }
    
    @objc fileprivate func onSegmentedControlDoubleTap(_ sender: TTSegmentedControl) {
        self.refreshIfNeed()
    }
    
    @objc func beginSendingPost(_ logic : PostLogicDeal) {
        self.subscribeViewController.beginSendingPost(logic)
//        postLogic = noti.object as? PostLogicDeal
//
//        if postLogic != nil {
//            postLogic?.delegate = self
//        }
//        self.tableView.setContentOffset(CGPoint.zero, animated: true)
//        self.tableView.reloadData()
    }
    
    // MARK: - ScrollView
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            if scrollView.contentOffset.x >= screenWidth {
                self.segmentedControl.selectedSegmentIndex = 1
            } else {
                self.segmentedControl.selectedSegmentIndex = 0
            }
        }
    }
    
    fileprivate func initialPublishButton() {
        self.publishButton = UIButton(type: .custom)
        self.publishButton?.setImage(UIImage(named: "btn_trend_publish"), for: .normal)
        
        self.view.addSubview(self.publishButton!)
        self.publishButton?.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-12)
            make.bottom.equalTo(bottomLayoutGuide.snp.top).offset(-16)
            make.height.equalTo(56)
            make.width.equalTo(56)
        }
        
        publishButton?.addTarget(self, action: #selector(onPublishButtonClicked(_:)), for: .touchUpInside)
    }
    
    @objc fileprivate func onPublishButtonClicked(_ button:UIButton){
        
//        let vc:PublishPageViewController = PublishPageViewController()
        let service: UGCService = GetService()
        if service.isSending {
            UIUtil.showHint("别着急哟，上一条动态正在发布中")
            return
        }
        
        
        
        UGCPublishPageUtil.postUGC(selectTopic: nil, subTopic: nil, fromViewController: self)
//        self.navigationController?.pushViewController(vc, animated: true)
//        if (!publishedBefore){
//            UserDefaults.standard.set(true, forKey: UGCHomePublishBeforeEveryVersionKey)
//            publishedBefore = true
//        }
    }
    
    @objc func refreshIfNeed() {
        
        if self.didAppear {
            if currentSelectIndex == 0 {
                self.subscribeViewController.refreshIfNeed(true)
            } else {
                self.recommendViewController.refreshIfNeed(true)
            }
        }
    }
    
    func scrollToSubscibeVC(firstSelected: Bool) {
        self.didFirstSelectedSegment = firstSelected
        segmentedControl.selectedSegmentIndex = 0
        onSegmentedControlChange(segmentedControl)
    }
    
    // mark:UGCCLIENT
    
    @objc func notifiesCountUpdated()  {
        
        self.updateTabBarBadgeValue()
    }
    
    @objc func followingFeedsUpdated() {
        
        self.updateTabBarBadgeValue()
    }
    
    func badgeStringForCount(count:Int) -> String {
        if count > 99 {
            return "…"
        }else {
            return "\(count)"
        }
    }
    
    @objc func updateBadgeValue() {
        updateTabBarBadgeValue()
    }
    
    fileprivate func updateTabBarBadgeValue() {
        
        let service:UGCService = GetService()
        let notifiycount = service.notifiesCount
        let notifiesUpdate = service.notifiesUpdate
        
        let value = self.badgeStringForCount(count: notifiycount)
        self.unreadView?.isHidden = notifiycount == 0
        self.unreadView?.badgeText = value
        self.followLabelRedPoint?.isHidden = !notifiesUpdate
        
        if notifiycount > 0 {
            self.tabBarController?.tabBar.hideBadge(onItemIndex: self.getMyTabIndex())
            self.tabBarController?.tabBar.showBadgeValue(value, onItemIndex: self.getMyTabIndex())
        } else if notifiesUpdate {
            self.tabBarController?.tabBar.hideBadgeValue(onItemIndex: Int(self.getMyTabIndex()))
            self.tabBarController?.tabBar.showBadge(onItemIndex: self.getMyTabIndex())
        } else {
            self.tabBarController?.tabBar.hideBadge(onItemIndex: self.getMyTabIndex())
            self.tabBarController?.tabBar.hideBadgeValue(onItemIndex: Int(self.getMyTabIndex()))
        }
    }
    
    func showPublishButton(isShowRecommendV : Bool){
        if(isShowRecommendV && currentSelectIndex == 0){
            self.publishButton?.isHidden = true
        }else if(!isShowRecommendV && currentSelectIndex == 0){
            self.publishButton?.isHidden = false
        }
    }
}
