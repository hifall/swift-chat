//
//  SIMChatKeyboardEmoji.swift
//  SIMChat
//
//  Created by sagesse on 9/20/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

/// 自定义键盘-表情面板
class SIMChatKeyboardEmoji: SIMView {
    /// 初始化
    convenience init(delegate: SIMChatKeyboardEmojiDelegate) {
        self.init(frame: CGRectZero)
        self.delegate = delegate
    }
    /// 构建
    override func build() {
        super.build()
        
        let line = SIMChatLine()
        let button = UIButton(type: .System)
        let vs = ["c" : collectionView,
                  "l" : line,
                  "b" : button,
                  "p" : pageControl]
        
        // config
        pageControl.pageIndicatorTintColor = UIColor.grayColor()
        pageControl.currentPageIndicatorTintColor = UIColor.darkGrayColor()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.pagingEnabled = true
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delaysContentTouches = false
        //collectionView.canCancelContentTouches = false
        collectionView.registerClass(SIMChatKeyboardEmojiContentCell.self, forCellWithReuseIdentifier: "Cell")
        
        line.contentMode = .Top
        line.tintColor = UIColor(hex: 0xBDBDBD)
        line.translatesAutoresizingMaskIntoConstraints = false
        
        button.tintColor = UIColor(hex: 0x7B7B7B)
        button.setTitle("发送", forState: .Normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        pageControl.currentPage = 0
        pageControl.numberOfPages = (collectionView.numberOfItemsInSection(0) + 21 - 1) / 21
        pageControl.hidesForSinglePage = true
        
        // add views
        addSubview(collectionView)
        addSubview(pageControl)
        addSubview(line)
        addSubview(button)
        
        // add constraints
        addConstraints(NSLayoutConstraintMake("H:|-(0)-[c]-(0)-|", views: vs))
        addConstraints(NSLayoutConstraintMake("H:|-(0)-[p]-(0)-|", views: vs))
        addConstraints(NSLayoutConstraintMake("H:|-(0)-[l]-(0)-|", views: vs))
        addConstraints(NSLayoutConstraintMake("V:|-(0)-[c]-(0)-[l(1)]-(40)-|", views: vs))
        
        addConstraints(NSLayoutConstraintMake("V:[p(16)]-(4)-[b(41)]-(0)-|", views: vs))
        addConstraints(NSLayoutConstraintMake("H:[b(64)]-(0)-|", views: vs))
        
        // add events
        button.addTarget(self, action: "onSendPress:", forControlEvents: .TouchUpInside)
        pageControl.addTarget(self, action: "onPageChanged:", forControlEvents: .ValueChanged)
        
        let tap = UITapGestureRecognizer(target: self, action: "onItemPress:")
        let press = UILongPressGestureRecognizer(target: self, action: "onItemLongPress:")
        
        tap.cancelsTouchesInView = false

        press.minimumPressDuration = 0.25
        
        collectionView.addGestureRecognizer(tap)
        collectionView.addGestureRecognizer(press)
    }
    /// 固定大小
    override func intrinsicContentSize() -> CGSize {
        return CGSizeMake(0, 216)
    }
    /// 代理.
    weak var delegate: SIMChatKeyboardEmojiDelegate?
    
    private lazy var emojiPreviewView = SIMChatKeyboardEmojiPreviewView(frame: CGRectMake(0, 0, 80, 80))
    private lazy var emojiPreviewLastPoint = CGPointZero
    
    private(set) lazy var pageControl = UIPageControl()
    private(set) lazy var collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: SIMChatKeyboardEmojiContentLayout())
    
    /// 生成表情列表
    private(set) lazy var emojis: [String] = {
        let emoji = { (x:UInt32) -> String in
            // 生成数字
            var idx = ((((0x808080F0 | (x & 0x3F000) >> 4) | (x & 0xFC0) << 10) | (x & 0x1C0000) << 18) | (x & 0x3F) << 24)
            // 生成字符串.
            return withUnsafePointer(&idx) {
                return NSString(bytes: $0, length: sizeof(idx.dynamicType), encoding: NSUTF8StringEncoding) as! String
            }
        }
        var rs = [String]()
        for i:UInt32 in 0x1F600 ..< 0x1F64F {
            if i < 0x1F641 || i > 0x1F644 {
                rs.append(emoji(i))
            }
        }
        for i:UInt32 in 0x1F680 ..< 0x1F6A4 {
            rs.append(emoji(i))
        }
        for i:UInt32 in 0x1F6A5 ..< 0x1F6C5 {
            rs.append(emoji(i))
        }
        return rs
    }()
}

// MARK: - UICollectionViewDelegate or UICollectionViewDataSource
extension SIMChatKeyboardEmoji : UICollectionViewDelegate, UICollectionViewDataSource {
    /// 滑动
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        pageControl.currentPage = Int((scrollView.contentOffset.x + scrollView.frame.width / 2.0) / scrollView.frame.width)
    }
    /// 页数
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojis.count + (emojis.count + 20 - 1) / 20
    }
    /// 创建单元格
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! SIMChatKeyboardEmojiContentCell
        let page = indexPath.row / 21
        let idx = indexPath.row - page
        var title: String?
        
        if idx < self.emojis.count && (indexPath.row == 0 || (indexPath.row + 1) % 21 != 0) {
            title = self.emojis[idx]
        }
        // 更新
        cell.emoji = title
        
        return cell
    }
}

/// MAKR: - /// Type
extension SIMChatKeyboardEmoji {
    /// 单元格
    private class SIMChatKeyboardEmojiContentCell : UICollectionViewCell {
        /// 初始化
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.build()
        }
        /// 反序列化
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            self.build()
        }
        /// 构建
        func build() {
            // config
            emojiView.frame = self.bounds
            emojiView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
            // add view
            contentView.addSubview(emojiView)
        }
        /// 标题
        dynamic var emoji: String? {
            set { return self.emojiView.emoji = newValue ?? "\u{7F}" }
            get { return self.emojiView.emoji }
        }
        
        private(set) lazy var emojiView = SIMChatEmojiView(frame: CGRectZero)
    }
    /// 内容的布局
    private class SIMChatKeyboardEmojiContentLayout : UICollectionViewLayout {
        
        var row = 3
        var column = 7
        
        /// t.
        override func collectionViewContentSize() -> CGSize {
            
            let count = self.collectionView?.numberOfItemsInSection(0) ?? 0
            let page = (count + (row * column - 1)) / (row * column)
            let frame = self.collectionView?.frame ?? CGRectZero
            
            return CGSizeMake(frame.width * CGFloat(page), 0)
        }
        ///
        override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
            
            var ats = [UICollectionViewLayoutAttributes]()
            
            // 生成
            let frame = self.collectionView?.bounds ?? CGRectZero
            let count = self.collectionView?.numberOfItemsInSection(0) ?? 0
            
            let w: CGFloat = 36//(frame.width / CGFloat(self.column))
            let h: CGFloat = 36//(frame.height / CGFloat(self.row))
            let yg: CGFloat = 10
            let xg: CGFloat = (frame.width - w * CGFloat(self.column)) / CGFloat(self.column + 1)
            
            for i in 0 ..< count {
                // 计算。
                var r = CGFloat((i / self.column) % self.row)
                var c = CGFloat((i % self.column))
                let idx = NSIndexPath(forItem: i, inSection: 0)
                let page = CGFloat(i / (row * column))
                // 最后一个必须面右下
                if i == count - 1 {
                    r = CGFloat(self.row - 1)
                    c = CGFloat(self.column - 1)
                }
                let a = self.layoutAttributesForItemAtIndexPath(idx) ?? UICollectionViewLayoutAttributes(forCellWithIndexPath: idx)
                // .
                a.frame = CGRectMake(xg + c * (w + xg) + page * frame.width, yg + r * (h + yg), w, h)
                // o
                ats.append(a)
            }
            
            return ats
        }
    }
    /// 预览视图(类型1)
    private class SIMChatKeyboardEmojiPreviewView : SIMImageView {
        /// 构建
        override func build() {
            super.build()
            
            // config
            image = SIMChatImageManager.images_emoji_preview
            contentMode = .ScaleAspectFit
            layer.anchorPoint = CGPointMake(1.0, 1.5)
            
            emojiView.translatesAutoresizingMaskIntoConstraints = false
            //emojiView.transform = CGAffineTransformMakeScale(1.2, 1.2)
            
            // add view
            addSubview(emojiView)
            
            // add constraints
            addConstraint(NSLayoutConstraintMake(emojiView, .CenterX, .Equal, self, .CenterX))
            addConstraint(NSLayoutConstraintMake(emojiView, .CenterY, .Equal, self, .CenterY, -4))
        }
        /// 标题
        dynamic var emoji: String? {
            set { return self.emojiView.emoji = newValue }
            get { return self.emojiView.emoji }
        }
        /// 将要有windows
        override func willMoveToWindow(newWindow: UIWindow?) {
            super.willMoveToWindow(newWindow)
            // 加点duang
            if newWindow != nil {
                self.emojiView.transform = CGAffineTransformMakeScale(0.8, 0.8)
                UIView.animateWithDuration(0.125, animations: {
                    self.emojiView.transform = CGAffineTransformMakeScale(1.6, 1.6)
                }, completion: { b in
                    // :)
                    guard b else {
                        // 恢复
                        self.emojiView.transform = CGAffineTransformMakeScale(1.2, 1.2)
                        return
                    }
                    // 继续动画
                    UIView.animateWithDuration(0.125) {
                        self.emojiView.transform = CGAffineTransformMakeScale(1.2, 1.2)
                    }
                })
            }
        }
        // :)
        lazy var emojiView = SIMChatEmojiView(frame: CGRectZero)
    }
}

// MARK: - Event
extension SIMChatKeyboardEmoji {
    /// 发送
    private dynamic func onSendPress(sender: AnyObject) {
        delegate?.chatKeyboardEmojiDidReturn?(self)
    }
    /// 点击表情
    private dynamic func onEmojiSelected(sender: String?) {
        if let value = sender {
            if value == "\u{7F}" {
                delegate?.chatKeyboardEmojiDidDelete?(self)
            } else {
                delegate?.chatKeyboardEmoji?(self, didSelectEmoji: value)
            }
        }
    }
    /// 选中选项
    private dynamic func onItemPress(sender: UIGestureRecognizer) {
        let pt = sender.locationInView(collectionView)
        if let idx = collectionView.indexPathForItemAtPoint(pt) {
            if let cell = collectionView.cellForItemAtIndexPath(idx) as? SIMChatKeyboardEmojiContentCell {
                self.onEmojiSelected(cell.emoji)
            }
        }
    }
    /// 选中选项
    private dynamic func onItemLongPress(sender: UILongPressGestureRecognizer) {
        
        let pt1 = sender.locationInView(collectionView)
        let pt2 = sender.locationInView(window)
        
        // 更新emoji
        if let idx = collectionView.indexPathForItemAtPoint(pt1) {
            if let cell = collectionView.cellForItemAtIndexPath(idx) as? SIMChatKeyboardEmojiContentCell {
                let tpt = cell.convertPoint(CGPointMake(cell.bounds.width / 2, 0), toView: window)
                emojiPreviewView.emoji = cell.emoji
                emojiPreviewLastPoint = tpt
            }
        }
        
        // 无论如何都更新
        emojiPreviewView.transform = CGAffineTransformMakeTranslation(pt2.x, pt2.y - 16)
//        // 超出边界? 随便
//        emojiPreviewView.hidden = !CGRectContainsPoint(CGRectMake(0, 0, 1, collectionView.bounds.height - 32), CGPointMake(0, pt1.y - 16))
        
        if sender.state == .Began {
            // 添加
            window?.addSubview(emojiPreviewView)
        } else if sender.state == .Ended || sender.state == .Cancelled {
            // 如果是正常结束
            if sender.state == .Ended {
                // 超出了
                if (pt1.y - 16) < 0 || (pt1.y - 16) > (collectionView.bounds.height - 32) {
                    let pt = self.emojiPreviewLastPoint
                    // 动画结束
                    UIView.animateWithDuration(0.25, animations: {
                        self.emojiPreviewView.transform = CGAffineTransformMakeTranslation(pt.x, pt.y)
                    }, completion: { b in
                        guard b else {
                            return
                        }
                        self.emojiPreviewView.removeFromSuperview()
                    })
                    return
                }
                // ok
                self.onEmojiSelected(emojiPreviewView.emoji)
            }
            // 删除
            emojiPreviewView.removeFromSuperview()
        }
    }
    /// 切换页面
    private dynamic func onPageChanged(sender: UIPageControl) {
        collectionView.setContentOffset(CGPointMake(collectionView.bounds.width * CGFloat(sender.currentPage), 0), animated: true)
    }
}

/// 代理
@objc protocol SIMChatKeyboardEmojiDelegate {

    optional func chatKeyboardEmojiDidDelete(chatKeyboardEmoji: SIMChatKeyboardEmoji)
    optional func chatKeyboardEmojiDidReturn(chatKeyboardEmoji: SIMChatKeyboardEmoji)
    
    optional func chatKeyboardEmoji(chatKeyboardEmoji: SIMChatKeyboardEmoji, didSelectEmoji emoji: String)
}