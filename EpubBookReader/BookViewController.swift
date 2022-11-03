// SkyEpub for iOS Advanced Demo IV  - Swift language
//
//  BookViewController.swift
//  SkyReader
//
//  Created by 하늘나무 on 2020/08/29.
//  Copyright © 2020 Dev. All rights reserved.
//

import UIKit

class ArrowView : UIView {
    private var _upSide:Bool = true
    private var _color:UIColor = UIColor.white
    
    var color:UIColor {
        get {
            return _color
        }
        set(newColor) {
            _color = newColor
            self.setNeedsDisplay()
        }
    }
    
    var upSide:Bool {
        get {
            return _upSide
        }
        set(newValue) {
            _upSide = newValue
            self.setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        let ctx:CGContext! = UIGraphicsGetCurrentContext();
        if (upSide) {
            ctx.beginPath()
            ctx.move(to: CGPoint(x:(rect.maxX)/2,y:rect.minY))
            ctx.addLine(to: CGPoint(x:rect.minX,y:rect.maxY))
            ctx.addLine(to: CGPoint(x:rect.maxX,y:rect.maxX))
            ctx.closePath()
        }else {
            ctx.beginPath()
            ctx.move(to: CGPoint(x:rect.minX,y:rect.minY))
            ctx.addLine(to: CGPoint(x:rect.maxX,y:rect.minY))
            ctx.addLine(to: CGPoint(x:(rect.maxX)/2,y:rect.maxY))
            ctx.closePath()
        }
        ctx.setFillColor(_color.cgColor)
        ctx.fillPath()
    }
}

class Theme {
    var textColor:UIColor = .black
    var labelColor:UIColor = .darkGray
    var backgroundColor:UIColor = .white
    var boxColor:UIColor = .white
    var borderColor:UIColor = .lightGray
    var iconColor:UIColor = .lightGray
    var selectedColor:UIColor = .blue
    var themeName:String = ""
    
    var sliderMinTrackColor:UIColor = .lightGray
    var sliderMaxTrackColor:UIColor = .lightGray
    var sliderThumbColor:UIColor = .lightGray
    
    init() {
        
    }
    
    init(themeName:String,textColor:UIColor, backgroundColor:UIColor, boxColor:UIColor, borderColor:UIColor, iconColor:UIColor,labelColor:UIColor,selectedColor:UIColor,sliderThumbColor:UIColor,sliderMinTrackColor:UIColor,sliderMaxTrackColor:UIColor) {
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.boxColor = boxColor
        self.borderColor = borderColor
        self.iconColor = iconColor
        self.labelColor = labelColor
        self.sliderThumbColor = sliderThumbColor
        self.sliderMinTrackColor = sliderMinTrackColor
        self.sliderMaxTrackColor = sliderMaxTrackColor
        self.selectedColor = selectedColor
    }
}

extension UIImage {
    func imageWithColor(color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        color.setFill()

        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.setBlendMode(CGBlendMode.normal)

        let rect = CGRect(origin: .zero, size: CGSize(width: self.size.width, height: self.size.height))
        context?.clip(to: rect, mask: self.cgImage!)
        context?.fill(rect)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}

extension UIButton {
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let margin: CGFloat = 10
        let hitArea = self.bounds.insetBy(dx: -margin, dy: -margin)
        return hitArea.contains(point)
    }
}


@IBDesignable
class SkySlider : UISlider {
    @IBInspectable var thumbImage: UIImage?{
        didSet {
            setThumbImage(thumbImage, for: .normal)
            setThumbImage(thumbImage, for: .highlighted)
        }
    }
}

enum SearchResultType {
  case normal,more,finished
}


class BookViewController: UIViewController,ReflowableViewControllerDataSource,ReflowableViewControllerDelegate,SkyProviderDataSource, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource  {
    var bookCode:Int = -1
    var sd:SkyData!
    var info:PageInformation!
    var bookInformation:BookInformation!
    var setting:Setting!
    var rv:ReflowableViewController!
   
    // Informations related to Hightlight/Note UI, Coordinations.
    var currentColor:UIColor!
    var currentHighlight:Highlight!
    var currentStartRect:CGRect!
    var currentEndRect:CGRect!
    var currentMenuFrame:CGRect!
    var isUpArrow:Bool!
    var currentArrowFrame:CGRect!
    var currentArrowFrameForNote:CGRect!
    var currentNoteFrame:CGRect!
    var currentPageInformation:PageInformation = PageInformation()
    
    var isRotationLocked:Bool = false
    var isBookmarked:Bool!
    var lastNumberOfSearched:Int = 0
    var searchScrollHeight:CGFloat = 0
    var searchResults:NSMutableArray = NSMutableArray()

    var fontNames:NSMutableArray = NSMutableArray()
    var fontAliases:NSMutableArray = NSMutableArray()
    var selectedFontOffsetY:CGFloat = 0
    var currentSelectedFontIndex:Int = 0
    var currentSelectedFontButton:UIButton!
    
    var themes:NSMutableArray = NSMutableArray()
    var currentTheme:Theme = Theme()
    var currentThemeIndex:Int = 0
    
    var highlights:NSMutableArray   = NSMutableArray()
    var bookmarks:NSMutableArray    = NSMutableArray()
    
    var isAutoPlaying:Bool = true
    var isLoop:Bool = false
    var autoStartPlayingWhenNewChapterLoaded:Bool = false
    var autoMoveChapterWhenParallesFinished:Bool = false
    var currentParallel:Parallel!
    var isChapterJustLoaded:Bool = false
    var isControlsShown:Bool = true
    var isScrollMode:Bool = false
    var isFontBoxMade:Bool = false

    var arrow:ArrowView!

    
    var snapView:UIView!
    var activityIndicator:UIActivityIndicatorView!
    

    @IBOutlet var listBox: UIView!
    @IBOutlet weak var listBoxTitleLabel: UILabel!
    @IBOutlet weak var listBoxResumeButton: UIButton!
    @IBOutlet weak var listBoxSegmentedControl: UISegmentedControl!
    @IBOutlet weak var listBoxContainer: UIView!
    @IBOutlet weak var contentsTableView: UITableView!
    @IBOutlet weak var notesTableView: UITableView!
    @IBOutlet weak var bookmarksTableView: UITableView!
    
    @IBOutlet weak var skyepubView: UIView!
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var fontButton: UIButton!
    @IBOutlet weak var bookmarkButton: UIButton!
    
    @IBOutlet weak var pageIndexLabel: UILabel!
    @IBOutlet weak var leftIndexLabel: UILabel!
    @IBOutlet weak var rightIndexLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet var menuBox: UIView!
    @IBOutlet var highlightBox: UIView!
    @IBOutlet var colorBox: UIView!
    
    @IBOutlet var noteBox: UIView!
    @IBOutlet weak var noteTextView: UITextView!
    
    @IBOutlet var searchBox: UIView!
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
        }
    }
    @IBOutlet weak var searchCancelButton: UIButton!
    @IBOutlet weak var searchScrollView: UIScrollView!
    
    @IBOutlet var baseView: UIView!
    var baseView2: UIView!
    
    @IBOutlet var fontBox: UIView!
    @IBOutlet weak var brightnessSlider: UISlider!
    @IBOutlet weak var decreaseBrightnessIcon: UIImageView!
    @IBOutlet weak var increaseBrightnessIcon: UIImageView!
    @IBOutlet weak var decreaseFontSizeButton: UIButton!
    @IBOutlet weak var increaseFontSizeButton: UIButton!
    @IBOutlet weak var decreaseLineSpacingButton: UIButton!
    @IBOutlet weak var increaseLineSpacingButton: UIButton!
    @IBOutlet weak var theme0Button: UIButton!
    @IBOutlet weak var theme1Button: UIButton!
    @IBOutlet weak var theme2Button: UIButton!
    @IBOutlet weak var theme3Button: UIButton!
    @IBOutlet weak var fontScrollView: UIScrollView!
    
    @IBOutlet var siBox: UIView!
    @IBOutlet weak var siBoxChapterTitleLabel: UILabel!
    @IBOutlet weak var siBoxPositionLabel: UILabel!
    
    @IBOutlet var mediaBox: UIView!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        self.updateSIBox()
    }
    
    @IBAction func sliderDragStarted(_ sender: Any) {
        self.showSIBox()
    }
    
    @IBAction func yellowPressed(_ sender: Any) {
        let color = self.getMarkerColor(colorIndex: 0)
        self.changeHighlightColor(newColor: color)
    }
    
    @IBAction func greenPressed(_ sender: Any) {
        let color = self.getMarkerColor(colorIndex: 1)
        self.changeHighlightColor(newColor: color)
    }
    
    @IBAction func bluePressed(_ sender: Any) {
        let color = self.getMarkerColor(colorIndex: 2)
        self.changeHighlightColor(newColor: color)
    }
    
    @IBAction func redPressed(_ sender: Any) {
        let color = self.getMarkerColor(colorIndex: 3)
        self.changeHighlightColor(newColor: color)
    }
    
    // about pagePosition concepts of skyepub, please refer to the link https://www.dropbox.com/s/heu7v0mjtyayh0q/PagePositionInBook.pdf?dl=1
    @IBAction func sliderDragEnded(_ sender: Any) {
        let position = Int32(slider.value)
        // if rv is global pagination mode,
        if rv.isGlobalPagination() {
            let pib = position
            let ppb = rv.getPagePositionInBook(pageIndexInBook: pib)
            rv.gotoPage(pagePositionInBook: ppb)  // goto the position in book by ppb which is calculated by pageIndex in book.
            print("sliderDragEnded for Global")
        }else {
            rv.gotoPage(pagePositionInBook: Double(slider.value), animated: false)
        }
        hideSIBox()
    }
    
    @IBAction func sliderDragEndedOutside(_ sender: Any) {
    }
    
    
    @IBAction func homePressed(_ sender: Any) {
        destroy()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func listPressed(_ sender: Any) {
        self.showListBox()
    }
    
    @IBAction func searchPressed(_ sender: Any) {
        self.showSearchBox(isCollapsed: true)
    }
    
    
    @IBAction func fontPressed(_ sender: Any) {
        self.showFontBox()
    }
    
    @IBAction func bookmarkPressed(_ sender: Any) {
        self.toggleBookmark()
    }
    
    func getBookPath()->String {
        let bookPath:String = "\(rv.baseDirectory!)/\(rv.fileName!)"
        return bookPath
    }
    
    func makeBookViewer() {
        // make ReflowableViewController object for epub.
        rv = ReflowableViewController(startPagePositionInBook: self.bookInformation.position)
        // set the color for blank screen.
        rv.setBlankColor(currentTheme.backgroundColor)
        // set the inital background color.
        rv.changeBackgroundColor(currentTheme.backgroundColor)
        // global pagination mode 0
        rv.setPagingMode(0)
        // set rv's datasource to self.
        rv.dataSource = self
        // set rv's delegate to self.
        rv.delegate = self
        
        // set the font of rv
        rv.fontSize = Int32(self.getRealFontSize(fontSizeIndex: setting.fontSize))
        // set lineSpacing of rv
        rv.lineSpacing = Int32(self.getRealLineSpacing(setting.lineSpacing))
        if setting.fontName != "Book Fonts" {
            rv.fontName = setting.fontName
        }
        // 0: none, 1:slide transition, 2: curling transition.
        rv.transitionType = Int32(setting.transitionType)
        // if true, sdk will show 2 pages when screen is landscape.
        rv.setDoublePagedForLandscape(self.setting.doublePaged)
        // if true, sdk will use gloabal pagination.
        rv.setGlobalPaging(self.setting.globalPagination)
        
        // set filename and bookCode to open.
        rv.fileName = self.bookInformation!.fileName
        rv.bookCode = self.bookInformation!.bookCode
        self.bookCode = Int(self.bookInformation!.bookCode)

        // set baseDirector of rv to booksDirectory
        let booksDirectory = sd.getBooksDirectory()
        rv.baseDirectory = booksDirectory
        
        // since 8.5.0, the path of epub can be set by setBookPath.
        let bookPath = self.getBookPath()        
        rv.setBookPath(bookPath)
                
        // 25% space (in both left most and right most margins)
        rv.setHorizontalGapRatio(0.25)
        // 20% space (in both top and bottom margins)
        rv.setVerticalGapRatio(0.20)
        
        // enable tts feature
        rv.setTTSEnabled(setting.tts)
        // set the speed of tts.
        // AVSpeechUtteranceMinimumSpeechRate,AVSpeechUtteranceDefaultSpeechRate,AVSpeechUtteranceMaximumSpeechRate
        // 0~1.0f   1.0f is max and fastest.
        rv.setTTSRate(AVSpeechUtteranceDefaultSpeechRate)
        // set the tone of tts.
        rv.setTTSPitch(1.0)
        // set the language of tts
        // if "auto" is set, TTS follows the language of epub itself.
        rv.setTTSLanguage("auto")
        // set the voice rate (voice speed) of mediaOverlay (1.0f is default, if 2.0 is set, twice times faster than normal speed.
        rv.setMediaOverlayRate(1.0)
        // disable scroll mode.
        rv.setScrollMode(false);
        
        // set License Key for Reflowable Layout
        rv.setLicenseKey("0000-0000-0000-0000");
        
        // make SkyProvider object to read epub reader.
        let skyProvider:SkyProvider = SkyProvider()
        // set skyProvider datasource
        skyProvider.dataSource = self
        // set skyProvider book to rv's book
        skyProvider.book = rv.book
        // set the content provider of rv as skyProvider
        rv.setContentProvider(skyProvider)
        // if true, you are able to draw highlight in custom.
        rv.setCustomDrawHighlight(true)
        // set the coordinates and size of rv
        rv.view.frame = self.skyepubView.bounds
        rv.view.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        // add tv to skyepubView which is made in story board as a container of epub viewer.
        self.skyepubView.addSubview(rv.view)
        self.addChild(rv)
        self.view.autoresizesSubviews = true
    }
    
    // make all custom themes.
    func makeThemes() {
        // Theme 0  -  White
        self.themes.add(Theme(themeName:"White", textColor: .black, backgroundColor: UIColor.init(red:252/255,green:252/255,blue: 252/255,alpha:1), boxColor: .white, borderColor: UIColor.init(red:198/255,green:198/255,blue: 200/255,alpha:1), iconColor: UIColor.init(red:0/255,green:2/255,blue: 0/255,alpha:1), labelColor: .black,     selectedColor:.blue, sliderThumbColor: .black,sliderMinTrackColor: .darkGray, sliderMaxTrackColor: UIColor.init(red:220/255,green:220/255,blue: 220/255,alpha:1)))
        // Theme 1 -   Brown
        self.themes.add(Theme(themeName:"Brown", textColor: .black, backgroundColor: UIColor.init(red:240/255,green:232/255,blue: 206/255,alpha:1), boxColor: UIColor.init(red:253/255,green:249/255,blue: 237/255,alpha:1), borderColor: UIColor.init(red:219/255,green:212/255,blue: 199/255,alpha:1), iconColor:UIColor.brown, labelColor: UIColor.init(red:70/255,green:52/255,blue: 35/255,alpha:1), selectedColor:.blue,sliderThumbColor: UIColor.init(red:191/255,green:154/255,blue: 70/255,alpha:1),sliderMinTrackColor: UIColor.init(red:191/255,green:154/255,blue: 70/255,alpha:1), sliderMaxTrackColor: UIColor.init(red:219/255,green:212/255,blue: 199/255,alpha:1)))
        // Theme 2 -  Dark
        self.themes.add(Theme(themeName:"Dark", textColor: UIColor.init(red:212/255,green:212/255,blue: 213/255,alpha:1), backgroundColor: UIColor.init(red:71/255,green:71/255,blue: 73/255,alpha:1), boxColor: UIColor.init(red:77/255,green:77/255,blue: 79/255,alpha:1), borderColor: UIColor.init(red:91/255,green:91/255,blue: 95/255,alpha:1), iconColor: UIColor.init(red:238/255,green:238/255,blue: 238/255,alpha:1), labelColor: UIColor.init(red:212/255,green:212/255,blue: 213/255,alpha:1),selectedColor:.yellow, sliderThumbColor: UIColor.init(red:254/255,green:254/255,blue: 254/255,alpha:1),sliderMinTrackColor: UIColor.init(red:254/255,green:254/255,blue: 254/255,alpha:1), sliderMaxTrackColor: UIColor.init(red:103/255,green:103/255,blue: 106/255,alpha:1)))
        // Theme 3 - Black
        self.themes.add(Theme(themeName:"Black",textColor: UIColor.init(red:175/255,green:175/255,blue: 175/255,alpha:1), backgroundColor: .black, boxColor: UIColor.init(red:44/255,green:44/255,blue: 46/255,alpha:1), borderColor: UIColor.init(red:90/255,green:90/255,blue: 92/255,alpha:1), iconColor: UIColor.init(red:241/255,green:241/255,blue: 241/255,alpha:1), labelColor: UIColor.init(red:169/255,green:169/255,blue: 169/255,alpha:1),selectedColor:.white, sliderThumbColor: UIColor.init(red:169/255,green:169/255,blue: 169/255,alpha:1),sliderMinTrackColor: UIColor.init(red:169/255,green:169/255,blue: 169/255,alpha:1), sliderMaxTrackColor: UIColor.init(red:42/255,green:42/255,blue: 44/255,alpha:1)))
    }
    
    // make user interface.
    func makeUI() {
        // if RTL (Right to Left writing like Arabic or Hebrew)
        if rv.isRTL() {
            // Inverse the direction of slider.
            slider.transform = slider.transform.rotated(by: CGFloat(180.0/180*3.141592));
        }
        
        if rv.isGlobalPagination() {
            slider.maximumValue = Float(rv.getNumberOfPagesInBook()-1)
            slider.minimumValue = 0;
            
            let globalPageIndex = rv.getPageIndexInBook()
            slider.value = Float(globalPageIndex)
        }

        isRotationLocked = setting.lockRotation
       
        self.makeFonts()
        
        arrow = ArrowView()
        arrow.isHidden = true
        self.view.addSubview(arrow)
        
        // listBox
        contentsTableView.delegate = self
        contentsTableView.dataSource = self
        bookmarksTableView.delegate = self
        bookmarksTableView.dataSource = self
        notesTableView.delegate = self
        notesTableView.dataSource = self
        
        fillFontScrollView()
        applyCurrentTheme()
        
        menuBox.isHidden = true
        colorBox.isHidden = true
        highlightBox.isHidden = true
    }
    
    func showBaseView() {
        self.view.addSubview(baseView)
        baseView.frame = self.view.bounds
        baseView.isHidden = false
        baseView.backgroundColor = .clear
        let gesture = UITapGestureRecognizer(target: self, action:#selector(self.baseClick(_:)))
        baseView.addGestureRecognizer(gesture)
    }
    
    func hideBaseView() {
        if !baseView.isHidden {
            baseView.removeFromSuperview()
            baseView.isHidden = true
        }
    }
    
    @objc func baseClick(_ sender:UITapGestureRecognizer){
        self.hideBoxes()
    }
    
    func addSkyErrorNotificationObserver() {
        NotificationCenter.default.addObserver(self,
        selector: #selector(didReceiveSkyErrorNotification(_:)),
        name: NSNotification.Name("SkyError"),
        object: nil)
    }
    
    func removeSkyErrorNotification() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("SkyError"), object: nil)
    }
    
    // if any error is reported by sdk.
    @objc func didReceiveSkyErrorNotification(_ notification: Notification) {
        guard let code: String = notification.userInfo?["code"] as? String else { return }
        guard let level: String = notification.userInfo?["level"] as? String else { return }
        guard let message: String = notification.userInfo?["message"] as? String else { return }
        
        NSLog("SkyError code %d level %d message:%@",code,level,message)
    }
    

    // display proper ui controls for rotation and direction.
    func recalcPageLabels() {
        if self.isPortrait() {
            pageIndexLabel.isHidden = false
            leftIndexLabel.isHidden = true
            rightIndexLabel.isHidden = true
        }else {
            if setting.doublePaged {
                pageIndexLabel.isHidden = true
                leftIndexLabel.isHidden = false
                rightIndexLabel.isHidden = false
            }else {
                pageIndexLabel.isHidden = false
                leftIndexLabel.isHidden = true
                rightIndexLabel.isHidden = true
            }
        }
    }
    

    // returns true when device is portrait.
    func isPortrait()->Bool {
        guard let interfaceOrientation = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.windowScene?.interfaceOrientation else { return false }
        var ret:Bool = false
        switch interfaceOrientation {
        case .portrait:
            ret = true
        case .portraitUpsideDown:
            ret = true
        case .landscapeLeft:
            ret = false
        case .landscapeRight:
            ret = false
        case .unknown:
            ret = false
        default:
            ret = false
        }
        return ret
    }

    
    // called when device has just been rotated.
    @objc func didRotated() {
        print("rotated")
        recalcPageLabels()
    }
    
    override var shouldAutorotate: Bool{
        return !self.isRotationLocked
    }
    
    
    // entry point of view controller.
    override func viewDidLoad() {
        super.viewDidLoad()
        var ad:AppDelegate!
        ad = UIApplication.shared.delegate as? AppDelegate
        sd = ad.data
        
        setting = sd.fetchSetting()
        makeThemes()
        currentThemeIndex = setting.theme
        currentTheme = themes.object(at: currentThemeIndex) as! Theme
        
        self.addSkyErrorNotificationObserver()
        NotificationCenter.default.addObserver(self, selector: #selector(didRotate), name: UIDevice.orientationDidChangeNotification, object: nil)

        self.makeBookViewer()
        self.makeUI()
        
        self.recalcPageLabels()
        
        currentColor = self.getMarkerColor(colorIndex: 0)
        
        var markerImage = self.getMakerImageFromColor(color: UIColor.yellow)
        
        isAutoPlaying = true
        autoStartPlayingWhenNewChapterLoaded = setting.autoStartPlaying
        autoMoveChapterWhenParallesFinished  = setting.autoLoadNewChapter
        isLoop = false
        // Do any additional setup after loading the view.
    }

    // this destory function should be called whenever is is dismissed.
    func destroy() {
        NotificationCenter.default.removeObserver(self)
        self.removeSkyErrorNotification()
        sd.updateBookPosition(bookInformation:self.bookInformation)
        sd.updateSetting(setting:setting)
        self.bookInformation = nil;
        rv.dataSource = nil;
        rv.delegate = nil;
//        rv.customView = nil;
        rv.removeFromParent()
        rv.view.removeFromSuperview()
        rv.destroy()
    }
    
    override func dismiss(animated flag: Bool,
                             completion: (() -> Void)?) {
        super.dismiss(animated: flag, completion: completion)
        NSLog("Dismissed");
    }
    
    // display page number or index.
    func changePageLabels(pageInformation:PageInformation) {
        var pi,pn:Int
        if rv.isGlobalPagination() {
            pi = pageInformation.pageIndexInBook;
            pn = pageInformation.numberOfPagesInBook;
        }else {
            pi = pageInformation.pageIndex;
            pn = pageInformation.numberOfPagesInChapter;
        }
        
        var dpi,dpn:Int
        
        if rv.isDoublePaged() && !self.isPortrait() {
            dpi = (pi*2)+1
            dpn = pn*2
            leftIndexLabel.text = "\(dpi)/\(dpn)"
            dpi = (pi*2)+2
            rightIndexLabel.text = "\(dpi)/\(dpn)"
        }else {
            dpi = pi+1
            dpn = pn
            pageIndexLabel.text = "\(dpi)/\(dpn)"
        }
    }
    
    // SKYEPUB SDK CALLBACK
    // called when page is moved.
    // PageInformation object contains all information about current page position.
    func reflowableViewController(_ rvc:ReflowableViewController,pageMoved pageInformation:PageInformation) {
        let ppb = pageInformation.pagePositionInBook
        let pageDelta = ((1/pageInformation.numberOfChaptersInBook)/pageInformation.numberOfPagesInChapter)
        
        if rv.isGlobalPagination() {
            if !rv.isPaging() {
                slider.minimumValue = 0;
                slider.maximumValue = Float(pageInformation.numberOfPagesInBook-1);
                slider.value = Float(pageInformation.pageIndexInBook)
                let cgpi = rv.getPageIndexInBook(pagePositionInBook:pageInformation.pagePositionInBook )
                print("slider.maximumValue                          \(Float(pageInformation.numberOfPagesInBook-1))")
                print("pageInformation.pageIndexInBook              \(pageInformation.pageIndexInBook)")
                print("rv.getPageIndexInBookByPagePosition(inBook:  \(cgpi)")
            }
        }else {
            slider.value = Float(ppb);
        }
        
        self.bookInformation.position = pageInformation.pagePositionInBook
        
        titleLabel.text = rvc.title
        changePageLabels(pageInformation: pageInformation)
        
        isBookmarked = sd.isBookmarked(pageInformation: pageInformation)
        
        currentPageInformation = pageInformation
        
        if autoStartPlayingWhenNewChapterLoaded && isChapterJustLoaded {
            if (rv.isMediaOverlayAvailable() && setting.mediaOverlay) || (rv.isTTSEnabled() && setting.tts && isAutoPlaying) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.rv.playFirstParallelInPage()
                    self.changePlayAndPauseButton()
                }
                
            }
        }
        
        isChapterJustLoaded = false
        
        let time = DispatchTime.now() + .seconds(0)
        DispatchQueue.main.asyncAfter(deadline: time) {
            self.processNoteIcons()
            self.processBookmark()
        }
    }
    
    // SKYEPUB SDK CALLBACK
    // called when a new chapter has been just loaded.
    func reflowableViewController(_ rvc: ReflowableViewController!, didChapterLoad chapterIndex: Int32) {
        if rv.isMediaOverlayAvailable() && setting.mediaOverlay {
            rv.setTTSEnabled(false)
            self.showMediaBox()
        }else if  rv.isTTSEnabled() {
            self.showMediaBox()
        }else {
            self.hideMediaBox()
        }
        isChapterJustLoaded = true
    }
    
    // SKYEPUB SDK CALLBACK
    // called when sdk needs to ask key to decrypt the encrypted epub. (encrypted by skydrm or any other drm which conforms to epub3 encrypt specification)
    // for more information about SkyDRM. please refer to the links below
    // https://www.dropbox.com/s/ctbe4yvhs60lq4n/SkyDRM%20Diagram.pdf?dl=1
    // https://www.dropbox.com/s/ch0kf0djrcxd241/SkyDRM%20Solution.pdf?dl=1
    // https://www.dropbox.com/s/xkxw4utpqq9frjw/SCS%20API%20Reference.pdf?dl=1
    func skyProvider(_ sp: SkyProvider!, keyForEncryptedData uuidForContent: String!, contentName: String!, uuidForEpub: String!) -> String! {
        let key = sd.keyManager.getKey(uuidForEpub,uuidForContent: uuidForContent);
        return key
    }
    
    // SKYEPUB SDK CALLBACK - DataSource
    // all highlights which belong to the chapter should be returned to SDK.
    // for more information about SkyEpub highlight system, please refer to https://www.dropbox.com/s/knnbxqdn077aace/Highlight%20Offsets.pdf?dl=1
    func reflowableViewController(_ rvc: ReflowableViewController!, highlightsForChapter chapterIndex: Int) -> NSMutableArray! {
        let highlights = sd.fetchHighlights(bookCode: self.bookCode, chapterIndex:chapterIndex)
        return highlights
    }
    
    // SKYEPUB SDK CALLBACK
    // called when a new highlight is about to be inserted.
    func reflowableViewController(_ rvc: ReflowableViewController!, didInsert highlight: Highlight!) {
        sd.insertHighlight(highlight: highlight)
        currentHighlight = highlight
        self.processNoteIcons()
        
    }
    
    // SKYEPUB SDK CALLBACK
    // called when a new highlight is about to be deleted.
    func reflowableViewController(_ rvc: ReflowableViewController!, didDelete highlight: Highlight!) {
        sd.deleteHighlight(highlight: highlight)
        self.processNoteIcons()
    }
    
    // SKYEPUB SDK CALLBACK
    // called when a new highlight is about to be updated.
    func reflowableViewController(_ rvc: ReflowableViewController!, didUpdate highlight: Highlight!) {
        sd.updateHighlight(highlight: highlight)
        self.processNoteIcons()
    }
    
    // SKYEPUB SDK CALLBACK
    // called when user touches on a highlight.
    func reflowableViewController(_ rvc: ReflowableViewController!, didHitHighlight highlight: Highlight!, at position: CGPoint, startRect: CGRect, endRect: CGRect) {
        NSLog("Highlight Hit")
        currentHighlight = highlight
        currentColor = UIColorFromRGB(rgbValue: UInt(highlight.highlightColor))
        self.showHighlightBox(startRect: startRect, endRect: endRect)
    }
    
    
    func calcMenuFrames(start startRect:CGRect, end endRect:CGRect) {
        let offset:CGFloat = 50.0
        let topHeight:CGFloat = 50.0
        let bottomHeight:CGFloat = 50.0
        var menuX:CGFloat = 0.0
        var arrowX:CGFloat = 0.0
        let arrowWidth:CGFloat = 20.0
        let arrowHeight:CGFloat = 20.0
        
        
        var topAdjust:CGFloat = 20
        
        if self.isPad() {
            topAdjust = 35
        }
        
        // check upper room for menubox
        if (startRect.origin.y-offset < topHeight) {
            if (endRect.origin.y+endRect.size.height + 50 > bottomHeight) { // there's no enough room.
                menuX = (endRect.size.width-menuBox.frame.size.width)/2+endRect.origin.x;
                arrowX = (endRect.size.width-arrowWidth)/2+endRect.origin.x;
                isUpArrow = true;
                currentMenuFrame = CGRect(x:menuX,y:endRect.origin.y+endRect.size.height+70,width:menuBox.bounds.size.width,height:menuBox.bounds.size.height);
            }
        }else {
            arrowX = (startRect.size.width-arrowWidth)/2+startRect.origin.x
            menuX = (startRect.size.width-menuBox.frame.size.width)/2+startRect.origin.x
            currentMenuFrame = CGRect(x:menuX,y:startRect.origin.y-topAdjust,width:menuBox.bounds.size.width,height:menuBox.bounds.size.height)
            isUpArrow = false
        }
        
        if (currentMenuFrame.origin.x < self.view.bounds.size.width*0.1) {
            currentMenuFrame.origin.x = self.view.bounds.size.width*0.1
        }else if ((currentMenuFrame.origin.x + currentMenuFrame.size.width) > self.view.bounds.size.width*0.9) {
            currentMenuFrame.origin.x = self.view.bounds.size.width*0.9-currentMenuFrame.size.width
        }
        
        if (arrowX < currentMenuFrame.origin.x+20) {
            arrowX = currentMenuFrame.origin.x+20;
        }
        if (arrowX > currentMenuFrame.origin.x + menuBox.bounds.size.width-40) {
            arrowX = currentMenuFrame.origin.x+menuBox.bounds.size.width-40;
        }
        if (isUpArrow) {
            currentArrowFrame = CGRect(x:arrowX,y:currentMenuFrame.origin.y-arrowHeight+4,width:arrowWidth,height:arrowHeight)
        }else {
            currentArrowFrame = CGRect(x:arrowX,y:currentMenuFrame.origin.y+currentMenuFrame.size.height-4,width:arrowWidth,height:arrowHeight)
        }
    }
    
    func showMenuBox(start startRect:CGRect, end endRect:CGRect) {
        self.calcMenuFrames(start: startRect, end: endRect)
        self.view.addSubview(menuBox)
        menuBox.frame = currentMenuFrame
        menuBox.isHidden = false
        showArrow(type:0)
    }
    
    func showArrow(type targetType:Int) {
        arrow.backgroundColor = .clear
        if (targetType==0) {
            arrow.color = UIColor.darkGray
        }else if targetType==1 {
            arrow.color = currentColor
        }
        
        arrow.upSide = isUpArrow
        arrow.frame = currentArrowFrame
        arrow.isHidden = false
    }
    
    func hideBoxes() {
        hideMenuBox()
        hideHighlightBox()
        hideColorBox()
        hideNoteBox()
        hideSearchBox()
        hideFontBox()
    }
    
    func hideMenuBox() {
        self.menuBox.removeFromSuperview()
        menuBox.isHidden = true
        arrow.isHidden = true
    }
    
    func hideNoteBox() {
        if self.noteBox.isHidden {
            return
        }
        self.saveNote()
        self.noteBox.removeFromSuperview()
        noteBox.isHidden = true
        arrow.isHidden = true
        noteTextView.text.removeAll()
        noteTextView.resignFirstResponder()
        hideBaseView()
    }
    
    func saveNote() {
        if self.noteBox.isHidden  {
            return
        }
        if currentHighlight == nil {
            return
        }
        if let text = noteTextView.text {
            let newColor:UIColor!
            if (currentHighlight.highlightColor==0) {
                newColor = self.getMarkerColor(colorIndex: 0)
            }else {
                newColor = self.UIColorFromRGB(rgbValue: UInt(currentHighlight.highlightColor))
            }
            
            if text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
                currentHighlight.note = ""
                currentHighlight.isNote = false
            }else {
                currentHighlight.note = text
                currentHighlight.isNote = true
            }
            rv.changeHighlight(currentHighlight, color: newColor, note: text)
        }
    }
    
    @IBAction func highlightPressed(_ sender: Any) {
        hideMenuBox()
        showHighlightBox()
        // makeSelectionHighlight will make selected text highlight and call didInsert highlight call back.
        rv.makeSelectionHighlight(currentColor)
    }
    
    @IBAction func notePressed(_ sender: Any) {
        hideMenuBox()
        rv.makeSelectionHighlight(currentColor)
        showNoteBox()
    }
    
   
    func showHighlightBox() {
        showBaseView()
        self.view.addSubview(highlightBox)
        highlightBox.frame.origin.x = currentMenuFrame.origin.x
        highlightBox.frame.origin.y = currentMenuFrame.origin.y
        highlightBox.backgroundColor = currentColor
        highlightBox.isHidden = false
        showArrow(type: 1)
    }
    
    func isPad() ->Bool {
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad)  {
            return true
        }else {
            return false
        }
    }
    
    func showNoteBox() {
        showBaseView()
        var startRect = rv.getStartRect(from: currentHighlight)
        var endRect = rv.getEndRect(from: currentHighlight)
        
        var topHegith:CGFloat = 50;
        var bottomHeight:CGFloat = 50;
        var noteX,noteY,noteWidth,noteHeight:CGFloat;
        noteWidth = 280;
        noteHeight = 230;
        var arrowWidth:CGFloat = 20
        var arrowHeight:CGFloat = 20
        var arrowX:CGFloat = 0
        var arrowY:CGFloat = 0

        arrow.color = currentColor
        let delta:CGFloat = 60
        
        if (self.isPad()) { // iPad
            var toDownSide:Bool!
            var targetRect:CGRect!
            // detect there's room in top side
            if ((startRect.origin.y - noteHeight)<topHegith) {
                toDownSide = true;  // reverse case
                targetRect = endRect;
                isUpArrow = true
            }else {
                toDownSide = false   // normal case
                targetRect = startRect;
                isUpArrow = true
            }
            
            if (!self.isPortrait()) { // landscape mode
                if (rv.isDoublePaged()) { // double Paged mode
                    // detect whether highlight is on left side or right side.
                    if (targetRect.origin.x < self.view.bounds.size.width/2) {
                        noteX = (self.view.bounds.size.width/2-noteWidth)/2;
                    }else {
                        noteX = (self.view.bounds.size.width/2-noteWidth)/2 + self.view.bounds.size.width/2  ;
                    }
                }else {
                    noteX = (targetRect.size.width-noteWidth)/2+targetRect.origin.x;
                }
            }else { // portrait mode
                noteX = (targetRect.size.width-noteWidth)/2+targetRect.origin.x;
            }
            
            if (noteX+noteWidth>self.view.bounds.size.width*0.9) {
                noteX = self.view.bounds.size.width*0.9 - noteWidth;
            }
            if (noteX<self.view.bounds.size.width * 0.1) {
                noteX = self.view.bounds.size.width * 0.1;
            }
            arrowX = (targetRect.size.width-arrowWidth)/2+targetRect.origin.x;
            if (arrowX<noteX+10) {
                arrowX = noteX+10;
            }
            if (arrowX>noteX+noteWidth-40) {
                arrowX = noteX+noteWidth-40;
            }
            // set noteY according to isDownSide flag.
            if (!toDownSide) { // normal case - test ok
                noteY = targetRect.origin.y - noteHeight-10;
                arrowY = noteY + noteHeight-5;
                currentArrowFrame = CGRect(x:arrowX,y:arrowY,width:arrowWidth,height:arrowHeight);
            }else { // normal case
                noteY = targetRect.origin.y + delta;
                arrowY = noteY-20;
                currentArrowFrame = CGRect(x:arrowX,y:arrowY,width:arrowWidth,height:arrowHeight);
            }
        }else { // in case of iPhone, coordinates are fixed.
            if (self.isPortrait()) {
                noteY = (self.view.bounds.size.height - noteBox.frame.size.height)/2;
            }else {
                noteY = (self.view.bounds.size.height - noteBox.frame.size.height)/2;
                noteHeight = 150;
                noteWidth = 500;
            }
            noteX = (self.view.bounds.size.width - noteWidth)/2;
        }
        
        currentNoteFrame = CGRect(x:noteX,y:noteY,width:noteWidth,height:noteHeight);
        
        noteBox.frame = currentNoteFrame;
        noteBox.backgroundColor = currentColor;
        self.view.addSubview(self.noteBox)
        self.noteBox.isHidden = false
    }
    
    @objc func noteIconPressed(_ sender: Any) {
        let noteIcon = sender as! UIButton
        let index = noteIcon.tag - 10000
        let pi:PageInformation = rv.getPageInformation()
        if let highlightsInPage = pi.highlightsInPage {
            let highlight = highlightsInPage[index] as! Highlight
            currentHighlight = highlight
            noteTextView.text = highlight.note
            currentStartRect = rv.getStartRect(from: currentHighlight)
            currentEndRect = rv.getEndRect(from: currentHighlight)
            self.showNoteBox()
        }
    }
    
    func getNoteIcon(highlight:Highlight,index:Int)->UIButton {
        let noteIcon = UIButton(type: .custom)
        let iconImage = self.getNoteIconImageByHighlightColor(highlightColor: highlight.highlightColor)
        noteIcon.setImage(iconImage, for: .normal)
        noteIcon.addTarget(self, action:#selector(self.noteIconPressed(_:)), for: .touchUpInside) //<- use `#selector(...)`
        noteIcon.contentMode = .center
        var mx:CGFloat = 0
        var my:CGFloat = 0
        let mw:CGFloat = 32
        let mh:CGFloat = 32
        mx = self.view.bounds.size.width - 10 - mw;
        my = CGFloat(highlight.top+32)
        if (self.isPad()) {
            if (!self.isPortrait()) { // doublePaged mode, landscape
                if (rv.isDoublePaged()) {
                    if (CGFloat(highlight.left)  < CGFloat(self.view.bounds.size.width/2)) {
                        mx = 50;
                        my = CGFloat(highlight.top+3);
                    }else {
                        mx = self.view.bounds.size.width - 50 - mw;
                        my = CGFloat(highlight.top+3);
                    }
                }
            }else { // portriat mode
                mx = self.view.bounds.size.width - 60 - mw;
                my = CGFloat(highlight.top + 5);
            }
        }
        noteIcon.tag = 10000+index
        noteIcon.frame = CGRect(x:mx,y:my,width:mw,height:mh)
        return noteIcon
    }
    
    func getNoteIconImageByHighlightColor(highlightColor:UInt32)->UIImage {
        let index  = self.getMarkerIndexByRGB(rgb: UInt32(highlightColor))
        var image:UIImage!
        switch index {
        case 0:
            image = UIImage(named: "yellowMemo.png")
        case 1:
            image = UIImage(named: "greenMemo.png")
        case 2:
            image = UIImage(named: "blueMemo.png")
        case 3:
            image = UIImage(named: "redMemo.png")
        default:
            image = UIImage(named: "yellowMemo.png")
        }
        return image
    }
    
    func removeNoteIcons() {
        for view in self.view.subviews {
            if (view.tag >= 10000) {
                view.removeFromSuperview()
            }
        }
    }
    
    
    func processNoteIcons() {
        self.removeNoteIcons()
        let pi:PageInformation = rv.getPageInformation()
        var hasNoteIcon = false
        if let highlightsInPage = pi.highlightsInPage {
            for index in 0..<highlightsInPage.count {
                let highlight = highlightsInPage[index] as! Highlight
                if !highlight.isNote {
                    continue
                }
                let noteIcon = self.getNoteIcon(highlight:highlight, index: index)
                self.view.addSubview(noteIcon)
                self.view.bringSubviewToFront(noteIcon)
                hasNoteIcon = true
            }
            if (highlightsInPage.count != 0 && hasNoteIcon) {
                rv.refresh()
            }
        }
    }
    
    
    
    func showHighlightBox(startRect:CGRect, endRect:CGRect) {
        calcMenuFrames(start: startRect, end: endRect)
        self.showHighlightBox()
    }
    
    func hideHighlightBox() {
        self.highlightBox.removeFromSuperview()
        highlightBox.isHidden = true
        arrow.isHidden = true
        hideBaseView()
    }
    
    func showColorBox() {
        showBaseView()
        self.view.addSubview(colorBox)
        colorBox.frame.origin.x = currentMenuFrame.origin.x
        colorBox.frame.origin.y = currentMenuFrame.origin.y
        colorBox.backgroundColor = currentColor
        colorBox.isHidden = false
        showArrow(type: 1)
    }
    
    func changeHighlightColor(newColor:UIColor) {
        currentColor = newColor
        highlightBox.backgroundColor = currentColor
        colorBox.backgroundColor = currentColor
        rv.changeHighlight(currentHighlight,color:currentColor)
        self.hideColorBox()
    }
    
    func hideColorBox() {
        self.colorBox.removeFromSuperview()
        colorBox.isHidden = true
        arrow.isHidden = true
        hideBaseView()
    }
    
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func RGBFromUIColor(color:UIColor)->UInt32 {
        let colorComponents = color.cgColor.components!
        let value = UInt32(0xFF0000*colorComponents[0] + 0xFF00*colorComponents[1] + 0xFF*colorComponents[2])
        return value
    }
    
    func getMarkerColor(colorIndex:Int32)->UIColor {
        var markerColor:UIColor!
        switch colorIndex {
        case 0: // yellow
            markerColor = UIColor(red: 238/255, green: 230/255, blue: 142/255, alpha: 1)
        case 1: //
            markerColor = UIColor(red: 218/255, green: 244/255, blue: 160/255, alpha: 1)
        case 2:
            markerColor = UIColor(red: 172/255, green: 201/255, blue: 246/255, alpha: 1)
        case 3:
            markerColor = UIColor(red: 249/255, green: 182/255, blue: 214/255, alpha: 1)
        default:
            markerColor = UIColor(red: 249/255, green: 182/255, blue: 214/255, alpha: 1)
        }
        return markerColor
    }
    
    func getMakerImageFromColor(color:UIColor)->UIImage {
        if isEqual(color: color,anotherColor: getMarkerColor(colorIndex: 0)) {
            return UIImage(named:"yellowmarker")!
        }
        if isEqual(color: color,anotherColor: getMarkerColor(colorIndex: 1)) {
            return UIImage(named:"greenmarker")!
        }
        if isEqual(color: color,anotherColor: getMarkerColor(colorIndex: 2)) {
            return UIImage(named:"bluemarker")!
        }
        if isEqual(color: color,anotherColor: getMarkerColor(colorIndex: 3)) {
            return UIImage(named:"redmarker")!
        }
        
        if isEqual(color: color,anotherColor: UIColor.yellow) {
            return UIImage(named:"yellowmarker")!
        }
        if isEqual(color: color,anotherColor: UIColor.green) {
            return UIImage(named:"greenmarker")!
        }
        if isEqual(color: color,anotherColor: UIColor.blue) {
            return UIImage(named:"bluemarker")!
        }
        if isEqual(color: color,anotherColor: UIColor.red) {
            return UIImage(named:"redmarker")!
        }
        
        return UIImage(named:"yellowmarker")!
    }
    
    
    func isEqual(color:UIColor, anotherColor:UIColor) ->Bool {
        let colorComponents = color.cgColor.components!
        let anotherColorComponents = anotherColor.cgColor.components!
        
        if  (abs(colorComponents[0]-anotherColorComponents[0])<0.00001) && (abs(colorComponents[1]-anotherColorComponents[1])<0.00001) &&
            (abs(colorComponents[2]-anotherColorComponents[2])<0.00001) {
            return true
        }
        return false
    }
    
    func getMarkerIndexByRGB(rgb:UInt32)->Int32 {
        for i in 0..<4 {
            let mc = getMarkerColor(colorIndex: Int32(i))
            let mrgb = RGBFromUIColor(color: mc)
            if mrgb==rgb  {
                return Int32(i)
            }
        }
        return 0
    }
    
    // SKYEPUB SDK CALLBACK
    // called when User selects text.
    func reflowableViewController(_ rvc: ReflowableViewController!, didSelectRange highlight: Highlight!, start startRect: CGRect, end endRect: CGRect) {
        currentHighlight = highlight
        currentStartRect = startRect
        currentEndRect = endRect
        showMenuBox(start:startRect,end:endRect)
    }
    
    // SKYEPUB SDK CALLBACK
    // called while user is changing the selection of text.
    func reflowableViewController(_ rvc: ReflowableViewController!, didSelectionChanged selectedText: String!) {
        self.hideMenuBox()
        self.hideHighlightBox()
    }
    
    // SKYEPUB SDK CALLBACK
    // called when user cancels text selection.
    func reflowableViewController(_ rvc: ReflowableViewController!, didSelectionCanceled lastSelectedText: String!) {
        self.hideMenuBox()
    }

    @IBAction func colorPressed(_ sender: Any) {
        hideHighlightBox()
        showColorBox()
    }
    
    @IBAction func trashPressed(_ sender: Any) {
        rv.deleteHightlight(currentHighlight)
        hideHighlightBox()
    }
    
    @IBAction func noteInHighlightBoxPressed(_ sender: Any) {
        hideHighlightBox()
        noteTextView.text = currentHighlight.note
        showNoteBox()
    }
    
    @IBAction func savePressed(_ sender: Any) {
        hideHighlightBox()
    }
    
    // SKYEPUB SDK CALLBACK
    // called when user touches on any area of book.
    func reflowableViewController(_ rvc: ReflowableViewController!, didDetectTapAt position: CGPoint) {
        print("Ta[ Detacted")
        if isControlsShown && menuBox.isHidden && colorBox.isHidden && highlightBox.isHidden {
            self.hideControls()
            self.hideMediaBox()
        } else {
            self.showControls()
            if (rv.isMediaOverlayAvailable() && setting.mediaOverlay) || rv.isTTSEnabled() {
                self.showMediaBox()
            }
        }
        self.hideHighlightBox()
        self.hideColorBox()
    }
    
    func highlightDrawnOnFront()->Bool {
        return false;
    }
    
    // SKYEPUB SDK CALLBACK
    // called whenever new custom drawing for highlight is required.
    func reflowableViewController(_ rvc: ReflowableViewController!, drawHighlight highlightRect: CGRect, context: CGContext!, highlight highlightColor: UIColor!, highlight: Highlight!) {
        if (!highlight.isTemporary) {
            if (self.highlightDrawnOnFront()) {
                context.clear(highlightRect)
                context.setBlendMode(.overlay)
                context.setFillColor(UIColor.blue.withAlphaComponent(0.7).cgColor)
                context.fill(highlightRect)
            }else {
                let markerImage = self.getMakerImageFromColor(color: highlightColor)
                context.draw(markerImage.cgImage!, in: highlightRect)
            }
        }else {
            if (!rv.isVerticalWriting()) {
                let markerImage = getMakerImageFromColor(color: highlightColor)
                let thinkness:CGFloat = 6.0
                let bottomRect = CGRect(x:highlightRect.origin.x,y:highlightRect.origin.y+highlightRect.size.height-thinkness+2, width:highlightRect.size.width, height:thinkness)
                context.draw(markerImage.cgImage!, in: bottomRect)
            }else {
                let markerImage = self.getMakerImageFromColor(color: highlightColor)
                let thickness:CGFloat = 6.0
                let bottomRect = CGRect(x:highlightRect.origin.x,y:highlightRect.origin.y, width:thickness,height:highlightRect.size.height)
                context.draw(markerImage.cgImage!, in: bottomRect)
            }
        }
     }
    
    func processBookmark() {
        if self.isBookmarked {
            bookmarkButton.setImage(UIImage(named: "bookmarked"), for: .normal)
        }else {
            bookmarkButton.setImage(UIImage(named: "bookmark"), for: .normal)
        }
    }
    
    func toggleBookmark() {
        sd.toggleBookmark(pageInformation: rv.getPageInformation())
        self.isBookmarked = !self.isBookmarked
        self.processBookmark()
    }
    
    func thumbImage() -> UIImage {
        var thumbImage:UIImage!
        thumbImage = UIImage(named: "skythumb")?.imageWithColor(color: currentTheme.sliderThumbColor)
        return thumbImage
    }
    
    // Global Pagination ================================================================
    func changeSliderUI(mode:Int) {
        if mode == 0 {
            self.slider.setThumbImage(self.thumbImage(), for: .normal)
            self.slider.setThumbImage(self.thumbImage(), for: .highlighted)
            self.slider.minimumTrackTintColor = UIColor.black
            self.slider.maximumTrackTintColor = UIColor.lightGray
        }
        
        if  mode == 1 {
            self.slider.setThumbImage(UIImage(named: "clearthumb"), for: .normal)
            self.slider.setThumbImage(UIImage(named: "clearthumb"), for: .highlighted)
            self.slider.minimumTrackTintColor = UIColor.lightGray
            self.slider.maximumTrackTintColor = UIColor.clear
        }
    }
    
    func processPaging(pagingInformation:PagingInformation) {
        if rv.isPaging() {
            let ci = pagingInformation.chapterIndex
            let cn = rv.getNumberOfChaptersInBook()
            let value = Float(ci) / Float(cn)
            slider.setValue(value, animated: true)
        }
        sd.insertPagingInformation(pagingInformation: pagingInformation)
    }
    
    func disableControlBeforePagination() {
        listButton.isHidden = true
        searchButton.isHidden = true
        fontButton.isHidden = true
        
        pageIndexLabel.isHidden = true
        leftIndexLabel.isHidden = true
        rightIndexLabel.isHidden = true
        
        self.changeSliderUI(mode: 1)
        
        slider.minimumValue = 0
        slider.maximumValue = 1
    }
    
    func enableControlAfterPagination() {
        listButton.isHidden = false
        searchButton.isHidden = false
        fontButton.isHidden = false
        
        self.changeSliderUI(mode: 0)
        
        if rv.isGlobalPagination() {
            slider.maximumValue = Float(rv.getNumberOfPagesInBook()-1)
            slider.minimumValue = 0;
            
            let globalPageIndex = rv.getPageIndexInBook()
            slider.value = Float(globalPageIndex)
        }
        let pg = PageInformation()
        pg.pageIndexInBook = Int(rv.getPageIndexInBook())
        pg.numberOfPagesInBook = Int(rv.getNumberOfPagesInBook())
        self.changePageLabels(pageInformation : pg)
        self.recalcPageLabels()
    }

    // SKYEPUB SDK CALLBACK
    // called when Global Pagination starts.
    func reflowableViewController(_ rvc: ReflowableViewController!, didStartPaging bookCode: Int32) {
        disableControlBeforePagination()
    }
    
    // SKYEPUB SDK CALLBACK
    // called whenever each chapter is paginated.
    // PagingInformation contains about all factors that can affect the numberOfPages of each chapter like numberOfPages, chapterIndex, the width or height of book, font and line spacing.
    func reflowableViewController(_ rvc: ReflowableViewController!, didPaging pagingInformation: PagingInformation!) {
        print("didPaging for \(pagingInformation.chapterIndex)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            self.processPaging(pagingInformation: pagingInformation)
        }
    }
    
    // SKYEPUB SDK CALLBACK
    // called when Global Pagination ends.
    func reflowableViewController(_ rvc: ReflowableViewController!, didFinishPaging bookCode: Int32) {
        self.enableControlAfterPagination()
    }
    
    // SKYEPUB SDK CALLBACK
    func reflowableViewController(_ rvc: ReflowableViewController!, numberOfPagesForPagingInformation pagingInformation:PagingInformation!) -> Int {
        //
        let pgi:PagingInformation! = sd.fetchPagingInformation(pagingInformation: pagingInformation)
        var nc = 0
        if pgi==nil {
            nc = 0
        }else {
            nc = pgi.numberOfPagesInChapter
        }
        return nc
    }
    
    // SKYEPUB SDK CALLBACK
    // if there's stored paging information which matches given paging information, return it to sdk to avoid repaging of the same chapter with the same conditions.
    func reflowableViewController(_ rvc: ReflowableViewController!, pagingInformationForPagingInformation pagingInformation: PagingInformation!) -> PagingInformation! {
        let pgi = sd.fetchPagingInformation(pagingInformation: pagingInformation)
        return pgi
    }
    
    // SKYEPUB SDK CALLBACK
    // returns all paging information about one book to SDK
    func reflowableViewController(_ rvc: ReflowableViewController!, anyPagingInformationsForBookCode bookCode: Int32, numberOfChapters: Int32) -> NSMutableArray! {
        return sd.fetchPagingInformationsForScan(bookCode: Int(bookCode), numberOfChapters: Int(numberOfChapters))
    }

    // SKYEPUB SDK CALLBACK
    // called when text inforamtion is extracted from each chapter. text information of each chapter can be stored external storage with or without encrypting.
    // and they will be used for searching, text speech, highlight or etc.
    func reflowableViewController(_ rvc: ReflowableViewController!, textExtracted bookCode: Int32, chapterIndex: Int32, text: String!) {
        let itemRef:ItemRef! = sd.fetchItemRef(bookCode: Int(bookCode), chapterIndex: Int(chapterIndex))
        if itemRef != nil {
            if !((text ?? "").isEmpty) {
                itemRef.text = text
                sd.updateItemRef(itemRef: itemRef)
            }
        }else {
            let newRef:ItemRef! = ItemRef()
            newRef.bookCode = bookCode
            newRef.chapterIndex = chapterIndex
            newRef.title = ""
            newRef.idref = ""
            newRef.href = ""
            newRef.fullPath = ""
            newRef.text = text
            sd.insertItemRef(itemRef: newRef)
        }
    }
    
    // SKYEPUB SDK CALLBACK
    // returns the text of chapter which is stored in permanant storage to SDK.
    func reflowableViewController(_ rvc: ReflowableViewController!, textForBookCode bookCode: Int32, chapterIndex: Int32) -> String! {
        //        NSLog(@"textForBookCode");
        let itemRef:ItemRef! = sd.fetchItemRef(bookCode: Int(bookCode), chapterIndex: Int(chapterIndex))
        if (itemRef == nil) {
            return nil;
        }
        let ret:String! = String(itemRef.text)
        return ret
    }
    
    
    // Saerch Routine ======================================================================================
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        let searchKey = searchTextField.text
        hideSearchBox()
        showSearchBox(isCollapsed: false)
        self.startSearch(key: searchKey)
        searchTextField.resignFirstResponder()
        return true
    }
    
    func clearSearchResults() {
        searchScrollHeight = 0
        searchResults.removeAllObjects()
        for sv in searchScrollView.subviews {
            sv.removeFromSuperview()
        }
        searchScrollView.contentSize.height = 0
    }
    
    func startSearch(key:String!)  {
        lastNumberOfSearched = 0
        
        self.clearSearchResults()
        rv.searchKey(key)
    }
    
    func searchMore() {
        rv.searchMore()
        rv.isSearching = true
    }

    func stopSearch() {
        rv.stopSearch()
    }
    
    var didApplyClearBox:Bool = false
    
    func showSearchBox(isCollapsed:Bool) {
        showBaseView()
        var searchText:String!
        searchText = searchTextField.text
        
        searchTextField.leftViewMode = .always
        
        let imageView = UIImageView();
        let image = UIImage(named: "magnifier");
        imageView.image = image;
        searchTextField.leftView = imageView;

        searchBox.layer.borderWidth = 1
        searchBox.layer.cornerRadius = 10
        isRotationLocked = true
        
        var sx,sy,sw,sh:CGFloat
        let rightMargin:CGFloat = 50.0
        let topMargin:CGFloat = 60.0 + view.safeAreaInsets.top
        let bottomMargin:CGFloat = 50.0 + view.safeAreaInsets.bottom
        
        
        if isCollapsed {
            if (searchText ?? "").isEmpty {
                self.clearSearchResults()
                searchTextField.becomeFirstResponder()
            }
        }
        
        if self.isPad() {
            searchBox.layer.borderColor = UIColor.lightGray.cgColor
            sx = self.view.bounds.size.width - searchBox.bounds.size.width - rightMargin
            sw = 400
            sy = topMargin
            if isCollapsed && (searchText ?? "").isEmpty  {
                searchScrollView.isHidden = true
                sh = 95
            }else {
                sh = self.view.bounds.size.height - (topMargin+bottomMargin)
                searchScrollView.isHidden = false
            }
        }else {
            searchBox.layer.borderColor = UIColor.clear.cgColor
            sx = 0
            sy = view.safeAreaInsets.top
            sw = self.view.bounds.size.width
            sh = self.view.bounds.size.height-(view.safeAreaInsets.top+view.safeAreaInsets.bottom)
        }
        
        searchBox.frame = CGRect(x:sx,y:sy,width:sw,height:sh)
        searchScrollView.frame = CGRect(x:30,y:100,width:searchBox.frame.size.width-55,height:searchBox.frame.height-(35+95))
        
        view.addSubview(searchBox)
        
        applyThemeToSearchBox(theme: currentTheme)
        searchBox.isHidden = false
    }
    
    func hideSearchBox() {
        if searchBox.isHidden {
            return
        }
        searchTextField.resignFirstResponder()
        searchBox.isHidden = true
        searchBox.removeFromSuperview()   // this line causes the constraint issues.
        isRotationLocked = setting.lockRotation
        hideBaseView()
    }
    
    @objc func searchTextFieldDidChange(_ textField: UITextField) {
        if !(searchTextField.text ?? "").isEmpty {
            applyThemeToSearchTextFieldClearButton(theme: currentTheme)
        }
    }
    
    func applyThemeToSearchTextFieldClearButton(theme:Theme) {
        if didApplyClearBox {
            return
        }
        for view in searchTextField.subviews {
            if view is UIButton {
                let button = view as! UIButton
                if let image = button.image(for: .highlighted) {
                    button.setImage(image.imageWithColor(color: .lightGray), for: .highlighted)
                    button.setImage(image.imageWithColor(color: .lightGray), for: .normal)
                    didApplyClearBox = true
                }
                if let image = button.image(for: .normal) {
                    button.setImage(image.imageWithColor(color: .lightGray), for: .highlighted)
                    button.setImage(image.imageWithColor(color: .lightGray), for: .normal)
                    didApplyClearBox = true
                }
            }
        }
    }
    
    func applyThemeToListBox(theme:Theme) {
        listBox.backgroundColor = theme.backgroundColor
        
        listBoxTitleLabel.textColor = theme.textColor
        listBoxResumeButton.setTitleColor(theme.textColor, for: .normal)
        
        if #available(iOS 13.0, *) {
            listBoxSegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
            listBoxSegmentedControl.setTitleTextAttributes([.foregroundColor: theme.labelColor], for: .normal)
        } else {
            listBoxSegmentedControl.tintColor = UIColor.darkGray
        }
    }
    
    func applyThemeToSearchBox(theme:Theme) {
        searchBox.backgroundColor = theme.boxColor
        searchBox.layer.borderWidth = 1
        searchBox.layer.borderColor = theme.borderColor.cgColor
        
        searchTextField.backgroundColor = UIColor.clear
        searchTextField.layer.masksToBounds = true
        searchTextField.layer.borderWidth = 1
        searchTextField.layer.cornerRadius = 5
        searchTextField.layer.borderColor = theme.borderColor.cgColor
        searchTextField.textColor = theme.textColor
        searchTextField.addTarget(self, action: #selector(self.searchTextFieldDidChange(_:)), for: .editingChanged)
        
        searchCancelButton.setTitleColor(theme.textColor, for: .normal)
        applyThemeToSearchTextFieldClearButton(theme: theme)
        
        let resultViews = searchScrollView.subviews.filter{$0 is SearchResultView}
        for i in 0..<resultViews.count {
            let resultView:SearchResultView = resultViews[i] as! SearchResultView
            resultView.headerLabel.textColor = theme.textColor
            resultView.contentLabel.textColor = theme.textColor
            resultView.bottomLine.backgroundColor = theme.borderColor
            resultView.bottomLine.alpha = 0.65
        }
    }
    
    func addSearchResult(searchResult:SearchResult, mode:SearchResultType) {
        var headerText:String = ""
        var contentText:String = ""
        
        let resultView = Bundle.main.loadNibNamed("SearchResultView", owner: self, options: nil)?.first as! SearchResultView
        let gotoButton = resultView.searchResultButton!
        
        if (mode == .normal) {
            let ci = searchResult.chapterIndex;
            let chapterTitle = rv.getChapterTitle(ci)
            var displayPageIndex = searchResult.pageIndex+1
            var displayNumberOfPages = searchResult.numberOfPagesInChapter
            if  rv.isDoublePaged() {
                displayPageIndex = displayPageIndex*2
                displayNumberOfPages = displayNumberOfPages*2
            }
            
            if (chapterTitle ?? "").isEmpty {
                if searchResult.numberOfPagesInChapter != -1 {
                    headerText = String(format: "%@ %d %@ %d/%d",NSLocalizedString("chapter",comment: ""),ci,NSLocalizedString("page",comment: ""),displayPageIndex,displayNumberOfPages)
                }else {
                    headerText = String(format:"%@ %d ",NSLocalizedString("chapter",comment: ""),ci)
                }
            }else {
                if searchResult.numberOfPagesInChapter != -1 {
                    headerText = String(format: "%@ %@ %d/%d",chapterTitle!,NSLocalizedString("page",comment: ""),displayPageIndex,displayNumberOfPages)
                }else {
                    headerText = String(format:"%@",chapterTitle!)
                }
            }
            
            contentText = searchResult.text
            searchResults.add(searchResult)
            
            gotoButton.tag = searchResults.count - 1
        }else if (mode == .more){
            headerText =  NSLocalizedString("search_more",comment: "")
            contentText = String(format:"%d %@",searchResult.numberOfSearched,NSLocalizedString("found",comment: ""))
            gotoButton.tag =  -2
        }else if (mode == .finished) {
            headerText =  NSLocalizedString("search_finished",comment: "")
            contentText = String(format:"%d %@",searchResult.numberOfSearched,NSLocalizedString("found",comment: ""))
            gotoButton.tag =  -1
        }
        
        resultView.headerLabel.text = headerText
        resultView.contentLabel.text = contentText
        
        resultView.headerLabel.textColor = currentTheme.textColor
        resultView.contentLabel.textColor = currentTheme.textColor
        resultView.bottomLine.backgroundColor = currentTheme.borderColor
        resultView.bottomLine.alpha = 0.65
        
        gotoButton.addTarget(self, action: #selector(self.gotoSearchPressed(_:)), for: .touchUpInside)
        
        var rx,ry,rw,rh:CGFloat
        rx = 0
        ry = searchScrollHeight
        rw = searchScrollView.bounds.size.width
        rh = 90
        
        resultView.frame = CGRect(x:rx,y:ry,width:rw,height:rh)
        
        searchScrollView.addSubview(resultView)
        searchScrollHeight+=rh
        searchScrollView.contentSize = CGSize(width:rw,height:searchScrollHeight)
        var co = searchScrollHeight-searchScrollView.bounds.size.height
        if (co<=0) {
            co = 0
        }
        searchScrollView.contentOffset  = CGPoint(x:0,y:co)
        
    }

    @IBAction func searchCancelPressed(_ sender: Any) {
        self.hideSearchBox()
    }
    
    @objc func gotoSearchPressed(_ sender: UIButton){
        let gotoSearchButton:UIButton = sender
        if (gotoSearchButton.tag == -1) {
            self.hideSearchBox()
        }else if (gotoSearchButton.tag == -2) {
            searchScrollHeight -= gotoSearchButton.bounds.size.height;
            searchScrollView.contentSize = CGSize(width:gotoSearchButton.bounds.size.width,height:searchScrollHeight)
            gotoSearchButton.superview!.removeFromSuperview()
            rv.searchMore()
        }else {
            self.hideSearchBox()
            let sr = searchResults.object(at: gotoSearchButton.tag) as! SearchResult
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // goto the position of searchResult.
                self.rv.gotoPage(searchResult: sr)
            }
        }
    }

    // SKYEPUB SDK CALLBACK
    // called when key is found while searching.
    func reflowableViewController(_ rvc: ReflowableViewController!, didSearchKey searchResult: SearchResult!) {
        self.addSearchResult(searchResult: searchResult, mode:.normal)
    }
    
    // SKYEPUB SDK CALLBACK
    // called after all searching process is over.
    func reflowableViewController(_ rvc: ReflowableViewController!, didFinishSearchAll searchResult: SearchResult!) {
        self.addSearchResult(searchResult: searchResult, mode:.finished)
    }
    
    // SKYEPUB SDK CALLBACK
    // called after searching process for one chapter is over.
    func reflowableViewController(_ rvc: ReflowableViewController!, didFinishSearchForChapter searchResult: SearchResult!) {
        rvc.pauseSearch()
        rvc.isSearching = false
        let cn = Int(searchResult.numberOfSearched) - Int(lastNumberOfSearched)
        if cn > 150 {
            self.addSearchResult(searchResult: searchResult, mode:.more)
            lastNumberOfSearched = Int(searchResult.numberOfSearched)
        }else {
            rvc.searchMore()
        }
    }
    
    
    // fonts
    // register custom fonts.
    func makeFonts() {
        self.addFont(name:"Book Fonts", alias:"Book Fonts")
        self.addFont(name:"Courier", alias:"Courier")
        self.addFont(name:"Arial", alias:"Arial")
        self.addFont(name:"Times New Roman", alias:"Times New Roman")
        self.addFont(name:"American Typewriter", alias:"American Typewriter")
        self.addFont(name:"Marker Felt", alias:"Marker Felt")
        self.addFont(name:"Mayflower Antique", alias:"Mayflower Antique")
        self.addFont(name:"Underwood Champion", alias:"Underwood Champion")
    }
    
    func addFont(name:String,alias:String) {
        fontNames.add(name)
        fontAliases.add(alias)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let touch = touches.first
        guard let location = touch?.location(in: self.view) else { return }
        if !fontBox.frame.contains(location) {
            print("Tapped outside the view")
        } else {
            print("Tapped inside the view")
        }
    }
    
    
    func showFontBox() {
        var fx:CGFloat = 0
        var fy:CGFloat = 0
        
        self.showBaseView()
        fontBox.isExclusiveTouch = true
        fontBox.isHidden = false
        self.view.addSubview(fontBox)
        
        let rightMargin:CGFloat = 50.0
        let topMargin:CGFloat = 60.0 + view.safeAreaInsets.top

        if self.isPad() {
            fx = self.view.bounds.size.width - fontBox.bounds.size.width - rightMargin
            fy = topMargin
        }else {
            fx = (view.frame.size.width-fontBox.frame.size.width)/2
            fy = view.safeAreaInsets.top+50
        }
        
        fontBox.frame.origin = CGPoint(x:fx,y:fy)
        
        if !isFontBoxMade  {
            self.fillFontScrollView()
        }
        self.focusSelectedFont()
        
        fontBox.layer.borderWidth = 1
        fontBox.layer.cornerRadius = 10
        fontScrollView.layer.borderWidth = 1
        fontScrollView.layer.cornerRadius = 10
        
        brightnessSlider.value = Float(setting.brightness)
    }
    
    func focusSelectedFont() {
        let itemHeight:CGFloat = 40
        var selectedFontOffsetY:CGFloat = 0
        let fontButtons = fontScrollView.subviews.filter{$0 is UIButton}
        for i in 0..<fontButtons.count {
            let fontButton:UIButton = fontButtons[i] as! UIButton
            if fontButton.isSelected {
                selectedFontOffsetY = fontButton.frame.origin.y - itemHeight
            }
            fontButton.setTitleColor(currentTheme.selectedColor, for: .selected)
            fontButton.setTitleColor(currentTheme.labelColor, for: .normal)
        }
        fontScrollView.contentOffset = CGPoint(x:0,y:selectedFontOffsetY)
    }
    
    func fillFontScrollView() {
        let itemHeight:CGFloat = 40
        var itemOffsetY:CGFloat = 0
        var fontIndex:Int = 0
        for i in 0..<fontNames.count {
            let fontName:String = fontNames.object(at: i) as! String
            let fontAlias:String = fontAliases.object(at: i) as! String
            let font:UIFont = UIFont(name:fontName,size:18.0) ?? UIFont.systemFont(ofSize: 18.0)
            let button:UIButton = UIButton(type: .custom)
            button.setTitle(fontAlias, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.setTitleColor(UIColor.init(red: 20/255, green: 40/255, blue: 230/255, alpha: 1.0), for: .selected)
            button.frame = CGRect(x:0,y:itemOffsetY,width:280,height:itemHeight)
            if fontName == setting.fontName {
                button.isSelected = true
                selectedFontOffsetY = itemOffsetY;
                currentSelectedFontIndex = fontIndex;
                currentSelectedFontButton = button;
            }
            button.tag = fontIndex
            button.titleLabel!.font = font
            
            button.showsTouchWhenHighlighted = true
            button.addTarget(self, action:#selector(self.fontNameButtonClick(_:)), for: .touchUpInside) //<- use `#selector(...)`
            fontScrollView.addSubview(button)
            fontIndex += 1
            itemOffsetY += itemHeight
        }
        
        fontScrollView.contentSize = CGSize(width:280, height:itemOffsetY)
        self.focusSelectedFont()
        isFontBoxMade = true
    }
    
    func hideFontBox() {
        fontBox.isHidden = true
        fontBox.removeFromSuperview()
        hideBaseView()
    }
    
    func increaseFontSize() {
        var fontName:String = setting.fontName
        if fontName  == "Book Fonts" {
            fontName = ""
        }
        if setting.fontSize != 4 {
            var fontSize = setting.fontSize!
            fontSize += 1
            // changeFontName changes font, fontSize.
            let ret = rv.changeFontName(fontName as String, fontSize: self.getRealFontSize(fontSizeIndex:fontSize))
            if ret {
                setting.fontSize = fontSize;
            }
        }
    }

    
    func decreaseFontSize() {
        var fontName:String = setting.fontName
        if fontName  == "Book Fonts" {
            fontName = ""
        }
        if (self.setting.fontSize != 0) {
            var fontSize = setting.fontSize!
            fontSize -= 1
            let ret = rv.changeFontName(fontName as String, fontSize:  self.getRealFontSize(fontSizeIndex:fontSize))
            if ret {
                setting.fontSize = fontSize;
            }
        }

    }
    
    func getRealLineSpacing(_ lineSpaceIndex:Int) ->Int {
        var rs:Int = 0
        switch lineSpaceIndex {
        case 0:
            rs = -1
        case 1:
            rs = 125
        case 2:
            rs = 150
        case 3:
            rs = 165
        case 4:
            rs = 180
        case 5:
            rs = 200
        default:
            rs = 150
        }
        return rs
      }

    func decreaseLineSpacing() {
        if setting.lineSpacing != 0 {
            var lineSpacingIndex = setting.lineSpacing!
            lineSpacingIndex -= 1
            let realLineSpacing = self.getRealLineSpacing(lineSpacingIndex)
            let ret = rv.changeLineSpacing(realLineSpacing)
            if ret {
                setting.lineSpacing = lineSpacingIndex
            }
        }
    }
    
    func increaseLineSpacing() {
        if setting.lineSpacing != 5 {
            var lineSpacingIndex = setting.lineSpacing!
            lineSpacingIndex += 1
            let realLineSpacing = self.getRealLineSpacing(lineSpacingIndex)
            let ret = rv.changeLineSpacing(realLineSpacing)
            if ret {
                setting.lineSpacing = lineSpacingIndex
            }
        }
    }

    func getRealFontSize(fontSizeIndex:Int) ->Int {
        var rs:Int = 0
        switch fontSizeIndex {
        case 0:
            rs = 15
        case 1:
            rs = 17
        case 2:
            rs = 20
        case 3:
            rs = 24
        case 4:
            rs = 27
        default:
            rs = 20
        }
        return rs
    }

    
    @objc func fontNameButtonClick(_ sender: Any) {
        if currentSelectedFontButton != nil {
            currentSelectedFontButton.isSelected = false
        }
        let button = sender as! UIButton
        button.isSelected = true
        currentSelectedFontButton = button
        currentSelectedFontIndex = button.tag
        var fontName = fontNames.object(at: currentSelectedFontIndex) as! String
        if fontName  == "Book Fonts" {
            fontName = ""
        }
        let ret = rv.changeFontName(fontName, fontSize: self.getRealFontSize(fontSizeIndex:setting.fontSize))
        if ret {
            setting.fontName = fontName
        }
    }
    
    @IBAction func decreaseFontSizeDown(_ sender: Any) {
        decreaseFontSizeButton.backgroundColor = .lightGray
        
    }
    
    @IBAction func decreaseFontSizePressed(_ sender: Any) {
        decreaseFontSizeButton.backgroundColor = .clear
        self.decreaseFontSize()
    }

    @IBAction func increaseFontSizeDown(_ sender: Any) {
        increaseFontSizeButton.backgroundColor = .lightGray
    }

    
    @IBAction func increaseFontSizePressed(_ sender: Any) {
        increaseFontSizeButton.backgroundColor = .clear
        self.increaseFontSize()
    }
    
    @IBAction func decreaseLineSpacingDown(_ sender: Any) {
        decreaseLineSpacingButton.backgroundColor = .lightGray
    }
    
    @IBAction func decreaseLineSpacingPressed(_ sender: Any) {
        decreaseLineSpacingButton.backgroundColor = .clear
        self.decreaseLineSpacing()
    }
    
    @IBAction func increaseLineSpacingDown(_ sender: Any) {
        increaseLineSpacingButton.backgroundColor = .lightGray
    }
    
    @IBAction func increaseLineSpacingPressed(_ sender: Any) {
        increaseLineSpacingButton.backgroundColor = .clear
        self.increaseLineSpacing()
    }
    
    func focusSelectedThemeButton() {
        theme0Button.layer.borderWidth = 1
        theme1Button.layer.borderWidth = 1
        theme2Button.layer.borderWidth = 1
        theme3Button.layer.borderWidth = 1
        
        switch currentThemeIndex {
        case 0: theme0Button.layer.borderWidth = 3
        case 1: theme1Button.layer.borderWidth = 3
        case 2: theme2Button.layer.borderWidth = 3
        case 3: theme3Button.layer.borderWidth = 3
        default:
            theme0Button.layer.borderWidth = 3
        }
        
        currentTheme = themes.object(at: currentThemeIndex) as! Theme
    }
    
    func applyCurrentTheme() {
        self.focusSelectedThemeButton()
        self.applyTheme(theme:currentTheme)
    }
    
    func applyTheme(theme:Theme) {
        applyThemeToBookViewer(theme: theme)
        applyThemeToFontBox(theme: theme)
        applyThemeToListBox(theme: theme)
        applyThemeToSearchBox(theme: theme)
        applyThemeToMediaBox(theme: theme)
    }
    
    func applyThemeToBookViewer(theme:Theme) {
        homeButton.tintColor = theme.iconColor
        listButton.tintColor = theme.iconColor
        searchButton.tintColor = theme.iconColor
        fontButton.tintColor = theme.iconColor
        bookmarkButton.tintColor = theme.iconColor
        
        titleLabel.textColor = theme.labelColor
        pageIndexLabel.textColor = theme.labelColor
        leftIndexLabel.textColor = theme.labelColor
        rightIndexLabel.textColor = theme.labelColor
        
        self.slider.setThumbImage(self.thumbImage(), for: .normal)
        self.slider.setThumbImage(self.thumbImage(), for: .highlighted)
        slider.minimumTrackTintColor = theme.sliderMinTrackColor
        slider.maximumTrackTintColor = theme.sliderMaxTrackColor
        
        self.view.backgroundColor = theme.backgroundColor
        rv.changeBackgroundColor(theme.backgroundColor)
        if theme.textColor == .black {
            rv.changeForegroundColor(nil)       // to set foreground color to nil will restore original book style color.
        }else {
            rv.changeForegroundColor(theme.textColor)
        }
    }
    
    func applyThemeToFontBox(theme:Theme) {
        fontBox.backgroundColor = theme.boxColor
        fontBox.layer.borderColor = theme.borderColor.cgColor
        
        brightnessSlider.thumbTintColor = UIColor.init(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
        brightnessSlider.minimumTrackTintColor = theme.sliderMinTrackColor
        brightnessSlider.maximumTrackTintColor = theme.sliderMaxTrackColor
            
        decreaseBrightnessIcon.tintColor = theme.iconColor
        increaseBrightnessIcon.tintColor = theme.iconColor
        
        increaseFontSizeButton.layer.borderColor = theme.borderColor.cgColor
        decreaseFontSizeButton.layer.borderColor = theme.borderColor.cgColor
        increaseFontSizeButton.tintColor = theme.iconColor
        decreaseFontSizeButton.tintColor = theme.iconColor
        
        increaseLineSpacingButton.layer.borderColor = theme.borderColor.cgColor
        increaseLineSpacingButton.tintColor = theme.iconColor
        decreaseLineSpacingButton.layer.borderColor = theme.borderColor.cgColor
        decreaseLineSpacingButton.tintColor = theme.iconColor
        
        fontScrollView.layer.borderColor = theme.borderColor.cgColor
        
        focusSelectedFont()
    }
    
    func applyThemeToMediaBox(theme:Theme) {
        prevButton.tintColor = theme.iconColor
        playButton.tintColor = theme.iconColor
        stopButton.tintColor = theme.iconColor
        nextButton.tintColor = theme.iconColor
    }
    
    
    @IBAction func theme0Pressed(_ sender: Any) {
        self.themePressed(themeIndex: 0)
    }
    
    @IBAction func theme1Pressed(_ sender: Any) {
        self.themePressed(themeIndex: 1)
    }
    
    @IBAction func theme2Pressed(_ sender: Any) {
        self.themePressed(themeIndex: 2)
    }
    
    @IBAction func theme3Pressed(_ sender: Any) {
        self.themePressed(themeIndex: 3)
    }
    
    func showSnapView() {
        self.snapView = self.view.snapshotView(afterScreenUpdates: false)
        self.view.addSubview(self.snapView)
    }
    
    func hideSnapView() {
        self.snapView.removeFromSuperview()
    }
    
    func showActivityIndicator() {
        self.activityIndicator = UIActivityIndicatorView.init(style: .large)
        if currentThemeIndex == 0 || currentThemeIndex == 1 {
            self.activityIndicator.color = UIColor.darkGray
        }else {
            self.activityIndicator.color = UIColor.white
        }
        self.activityIndicator.startAnimating()
        self.activityIndicator.center = self.view.center
        self.view.addSubview(self.activityIndicator)
    }
    
    func hideActivityIndicator() {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.removeFromSuperview()
    }
    
    func themePressed(themeIndex:Int) {
        if themeIndex == currentThemeIndex {
            return
        }
        if setting.transitionType == 2 {
            self.showSnapView()
            self.showActivityIndicator()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.hideActivityIndicator()
                self.hideSnapView()
            }
        }
        currentThemeIndex = themeIndex;
        setting.theme = currentThemeIndex
        applyCurrentTheme()
    }
    
    @IBAction func brightnessSliderChanged(_ sender: Any) {
        setting.brightness = Double((sender as! UISlider).value)
        UIScreen.main.brightness = CGFloat(setting.brightness)
    }
    
    
    // listBox
    @IBAction func listBoxSegmentedControlChanged(_ sender: UISegmentedControl) {
        print(listBoxSegmentedControl.selectedSegmentIndex)
        self.showTableView(index:listBoxSegmentedControl.selectedSegmentIndex)
    }

    @IBAction func listBoxResumePressed(_ sender: Any) {
        self.hideListBox()
    }
    
    func showListBox() {
        showBaseView()
        isRotationLocked = true
        var sx,sy,sw,sh:CGFloat
        listBox.layer.borderColor = UIColor.clear.cgColor
        sx = view.safeAreaInsets.left * 0.4
        sy = view.safeAreaInsets.top
        sw = self.view.bounds.size.width-(view.safeAreaInsets.left+view.safeAreaInsets.right) * 0.4
        sh = self.view.bounds.size.height-(view.safeAreaInsets.top+view.safeAreaInsets.bottom)
        
        listBox.frame = CGRect(x:sx,y:sy,width: sw,height: sh)
        
        listBoxTitleLabel.text = rv.title
        
        reloadContents()
        reloadHighlights()
        reloadBookmarks()
        
        showTableView(index: listBoxSegmentedControl.selectedSegmentIndex)
        
        view.addSubview(listBox)
        applyThemeToListBox(theme: currentTheme)
        listBox.isHidden = false
    }
    
    func hideListBox() {
        if listBox.isHidden {
            return
        }
        listBox.isHidden = true
        listBox.removeFromSuperview()   // this line causes the constraint issues.
        isRotationLocked = setting.lockRotation
        hideBaseView()
    }
    
    func showTableView(index:Int) {
        contentsTableView.isHidden = true
        notesTableView.isHidden = true
        bookmarksTableView.isHidden = true
        if (index==0) {
            contentsTableView.isHidden = false
        }else if (index==1) {
            notesTableView.isHidden = false
        }else if (index==2) {
            bookmarksTableView.isHidden = false
        }
    }
    
    func reloadContents() {
//        if !isContentsTableViewLoaded {
            contentsTableView.reloadData()
//            isContentsTableViewLoaded = true
//        }
    }
    
    func reloadHighlights() {
        self.highlights = self.sd.fetchHighlights(bookCode: self.bookCode)
        notesTableView.reloadData()
    }
    
    func reloadBookmarks() {
        self.bookmarks = self.sd.fetchBookmarks(bookCode: self.bookCode)
        bookmarksTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var ret:Int = 0
        if (tableView.tag==200) {
            ret  = rv.navMap.count
        }else if (tableView.tag==201) {
            ret  = self.highlights.count
        }else if (tableView.tag==202) {
            ret  = self.bookmarks.count
        }
        return ret
    }
    
    // for more information about navMap and navPoint in epub, please refer to https://www.dropbox.com/s/yko3mq35if9ix68/NavMap.pdf?dl=1
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        if (tableView.tag==200) {
            // constructs the table of contents.
            // navMap and navPoint contains the information of TOC (table of contents)
            let cnp:NavPoint! = rv.getCurrentNavPoint()
            if let cell:ContentsTableViewCell = contentsTableView.dequeueReusableCell(withIdentifier: "contentsTableViewCell", for: indexPath) as? ContentsTableViewCell {
                let np:NavPoint = rv.navMap.object(at: index) as! NavPoint
                var leadingSpaceForDepth:String = ""
                for _ in 0..<np.depth {
                    leadingSpaceForDepth += "   "
                }
                cell.chapterTitleLabel.text = leadingSpaceForDepth + np.text
                cell.positionLabel.text = ""
                cell.chapterTitleLabel.textColor = currentTheme.textColor
                cell.positionLabel.textColor = currentTheme.textColor
                
                if np.chapterIndex == currentPageInformation.chapterIndex {
                    cell.chapterTitleLabel.textColor = UIColor.systemIndigo
                }
                if cnp != nil && np == cnp {
                    cell.chapterTitleLabel.textColor = UIColor.systemBlue
                }
                
                return cell
            }
        }else if (tableView.tag==201) {
            // constructs the table of highlights
            if let cell:NotesTableViewCell = notesTableView.dequeueReusableCell(withIdentifier: "notesTableViewCell", for: indexPath) as? NotesTableViewCell {
                let highlight:Highlight = highlights.object(at: index) as! Highlight
                cell.positionLabel.text = rv.getChapterTitle(highlight.chapterIndex)
                cell.highlightTextLabel.text = highlight.text
                cell.noteTextLabel.text = highlight.note
                cell.datetimeLabel.text = highlight.datetime
                
                cell.positionLabel.textColor = currentTheme.textColor
                cell.highlightTextLabel.textColor = .black
                cell.noteTextLabel.textColor = currentTheme.textColor
                cell.datetimeLabel.textColor = currentTheme.textColor

                cell.highlightTextLabel.backgroundColor =  UIColorFromRGB(rgbValue: UInt(highlight.highlightColor))
                return cell
            }
        }else if (tableView.tag==202) {
            // constructs the table of bookmarks
            if let cell:BookmarksTableViewCell = bookmarksTableView.dequeueReusableCell(withIdentifier: "bookmarksTableViewCell", for: indexPath) as? BookmarksTableViewCell {
                let pg:PageInformation = bookmarks.object(at: index) as! PageInformation
                cell.positionLabel.text = rv.getChapterTitle(Int32(pg.chapterIndex))
                cell.datetimeLabel.text = pg.datetime
                cell.datetimeLabel.textColor = currentTheme.textColor
                cell.positionLabel.textColor = currentTheme.textColor
                return cell
            }
        }
        return UITableViewCell()
    }
    
    // called when user presses one item of tables
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        if (tableView.tag==200) {
            let np:NavPoint = rv.navMap.object(at: index) as! NavPoint
            rv.gotoPage(navPoint: np)
            self.hideListBox()
        }else if (tableView.tag==201) {
            let highlight:Highlight = highlights.object(at: index) as! Highlight
            rv.gotoPage(highlight: highlight)
            self.hideListBox()
        }else if (tableView.tag==202) {
            let pg:PageInformation = bookmarks.object(at: index) as! PageInformation
            rv.gotoPage(pagePositionInBook: pg.pagePositionInBook, animated: false)
            self.hideListBox()
        }
    }
    
    // bookmarks and highlights list are editable to delete a item from the list.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (tableView.tag==201 || tableView.tag==202) {
            return true
        }
        return false
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let index = indexPath.row
            if (tableView.tag==201) {
                let highlight:Highlight = highlights.object(at: index) as! Highlight
                self.sd.deleteHighlight(highlight: highlight)
                self.reloadHighlights()
            }else if (tableView.tag==202) {
                let pi:PageInformation = bookmarks.object(at: index) as! PageInformation
                self.sd.deleteBookmark(pageInformation: pi)
                self.reloadBookmarks()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let index = indexPath.row
        var height:CGFloat = 70
        if (tableView.tag == 200) {
            height = 40
        }else if (tableView.tag == 201) {
            let highlight:Highlight = highlights.object(at: index) as! Highlight
            if highlight.isNote {
                height = 125
            }else {
                height = 100
            }
        }else if (tableView.tag == 202) {
            height = 67
        }
        return height
    }
    
    // SIBox - slider IndexBox
    func applyThemeToSIBox(theme:Theme) {
        siBox.layer.borderWidth = 1
        siBox.layer.cornerRadius = 10
        
        if currentThemeIndex == 0 || currentThemeIndex == 1 {
            siBox.backgroundColor = theme.iconColor
            siBox.layer.borderColor = theme.textColor.cgColor
            siBoxChapterTitleLabel.textColor = theme.backgroundColor
            siBoxPositionLabel.textColor = theme.backgroundColor
        }else {
            siBox.backgroundColor = theme.boxColor
            siBox.layer.borderColor = UIColor.darkGray.cgColor
            siBoxChapterTitleLabel.textColor = theme.textColor
            siBoxPositionLabel.textColor = theme.textColor
        }
    }
    
    func showSIBox() {
        var sx,sy,sw,sh:CGFloat
        sx = (view.frame.size.width-siBox.frame.size.width)/2
        sy = view.frame.height-135
        sw = siBox.frame.width
        sh = siBox.frame.height
        if !rv.isGlobalPagination() {
            sh = 42;
            sy = sy + 10
            siBoxPositionLabel.isHidden = true
        }else {
            sh = 52;
            siBoxPositionLabel.isHidden = false
        }
        siBox.frame = CGRect(x:sx,y:sy,width: sw,height: sh)
        view.addSubview(siBox)
        applyThemeToSIBox(theme: currentTheme)
        siBox.isHidden = false
    }
    
    func hideSIBox() {
        if siBox.isHidden {
            return
        }
        siBox.isHidden = true
        siBox.removeFromSuperview()   // this line causes the constraint issues.
    }
    
    func updateSIBox() {
        var ppb:Double = 0
        var pi:PageInformation!
        let pib = slider.value
        
        if (rv.isGlobalPagination()) {
            ppb = rv.getPagePositionInBook(pageIndexInBook: Int32(pib))
        }else {
            ppb = Double(slider.value)
        }
        pi = rv.getPageInformationAtPagePosition(inBook: ppb)
        
        let ci = pi.chapterIndex
        var caption:String!
        
        if slider.value == slider.maximumValue {
            caption = "The End"
        }else if (pi.chapterTitle ?? "").isEmpty {
            caption = "Chapter \(ci)th"
        }else {
            caption = pi.chapterTitle
        }
        
        siBoxChapterTitleLabel.text = caption
        if rv.isGlobalPagination() {
            let gpi = Int(slider.value)
            siBoxPositionLabel.text = "\(gpi + 1)"
        }else {
            siBoxPositionLabel.text = ""
        }
    }
    
    // Toggle UIControls
    func showControls() {
        homeButton.isHidden = false
        listButton.isHidden = false
        fontButton.isHidden = false
        searchButton.isHidden = false
        if !self.isScrollMode {
            slider.isHidden = false
        }
        isControlsShown = true
    }

    func hideControls() {
        homeButton.isHidden = true
        listButton.isHidden = true
        fontButton.isHidden = true
        searchButton.isHidden = true
        slider.isHidden = true
        isControlsShown = false
    }
    
    
    // MediaOverlay && TTS
    func showMediaBox() {
        self.view.addSubview(mediaBox)
        applyThemeToMediaBox(theme: currentTheme)
        mediaBox.frame.origin.x = titleLabel.frame.origin.x
        mediaBox.frame.origin.y = listButton.frame.origin.y - 7
        mediaBox.isHidden = false
        titleLabel.isHidden = true
    }
    
    func hideMediaBox() {
        self.mediaBox.removeFromSuperview()
        mediaBox.isHidden = true
        titleLabel.isHidden = false
    }
    
    func changePlayAndPauseButton() {
        if !rv.isPlayingStarted() {
            playButton.setImage(UIImage(named: "play"), for: .normal)
        }else if rv.isPlayingPaused() {
            playButton.setImage(UIImage(named: "play"), for: .normal)
        }else {
            playButton.setImage(UIImage(named: "pause"), for: .normal)
        }
    }
    
    // MediaBox buttons.
    // when prev butotn presed.
    @IBAction func prevPressed(_ sender: Any) {
        self.playPrev()
    }
    
    @IBAction func playPressed(_ sender: Any) {
        self.playAndPause()
    }
    
    @IBAction func stopPressed(_ sender: Any) {
        self.stopPlaying()
    }
        
    @IBAction func nextPressed(_ sender: Any) {
        self.playNext()
    }
    
    
    // play or pause the parallel of MediaOverlay or TTS.
    func playAndPause() {
        if !rv.isPlayingStarted() {
            rv.playFirstParallelInPage()
            isAutoPlaying = true
        }else if rv.isPlayingPaused() {
            rv.resumePlayingParallel()
            isAutoPlaying = true
        }else {
            rv.pausePlayingParallel()
            isAutoPlaying = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.changePlayAndPauseButton()
        }
    }

    // stop playing the parallel.
    func stopPlaying() {
        rv.stopPlayingParallel()
        if !rv.isTTSEnabled() {
            rv.restoreElementColor()
        }else {
            rv.removeParallelHighlights()
        }
        isAutoPlaying = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.changePlayAndPauseButton()
        }
    }

    // play the previous parallel.
    func playPrev() {
        rv.playPrevParallel()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.changePlayAndPauseButton()
        }
    }

    // play the next paralle.
    func playNext() {
        rv.playNextParallel()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.changePlayAndPauseButton()
        }
    }
    
    // SKYEPUB SDK CALLBACK
    // called when playing a parallel starts in MediaOverlay or TTS
    // make the text of speech highlight while playing.
    func reflowableViewController(_ rvc: ReflowableViewController!, parallelDidStart parallel: Parallel!) {
        if rv.pageIndexInChapter() != parallel.pageIndex {
            rv.gotoPage(pageIndexInChapter: parallel.pageIndex)
        }
        if (setting.highlightTextToVoice) {
            if !rv.isTTSEnabled() {     // for MediaOverlay
                rv.changeElementColor("#FFFF00", hash: parallel.hash!)
            }else {                     // for TTS
                rv.markParallelHighlight(parallel, color: self.getMarkerColor(colorIndex: 1))
            }
        }
        currentParallel = parallel
    }
    
    // SKYEPUB SDK CALLBACK
    // called when playing a parallel ends in MediaOverlay or TTS
    func reflowableViewController(_ rvc: ReflowableViewController!, parallelDidEnd parallel: Parallel!) {
        if !rv.isTTSEnabled() {
            if setting.highlightTextToVoice {
                rv.restoreElementColor()
            }
            if isLoop {
                rv.playPrevParallel()
            }
        }else {
            if setting.highlightTextToVoice {
                rv.removeParallelHighlights()
            }
        }
    }

    // SKYEPUB SDK CALLBACK
    // called after playing all parallels are finished in MediaOverlay or TTS.
    func parallesDidEnd(_ rvc: ReflowableViewController!) {
        rv.restoreElementColor()
        rv.stopPlayingParallel()
        self.changePlayAndPauseButton()
        isAutoPlaying = true
        if autoMoveChapterWhenParallesFinished {
            autoStartPlayingWhenNewChapterLoaded = true
            rv.gotoNextChapter()
        }
    }
    
    // SKYEPUB SDK CALLBACK
    // if you need to modify text to speech (like numbers, punctuation or etc), you can send over the modifed text of original rawString.
    func reflowableViewController(_ rvc: ReflowableViewController!, postProcessText rawString: String!) -> String! {
        return rawString
    }
    

    
    func reflowableViewController(_ rvc: ReflowableViewController!, didHitLink urlString: String!) {
        print("didHitLink "+urlString)
    }
    
    func reflowableViewController(_ rvc: ReflowableViewController!, didHitAudio urlString: String!) {
        print("didHitAudio")
    }
    
    func reflowableViewController(_ rvc: ReflowableViewController!, didHitImage urlString: String!) {
        print("didHitImage "+urlString)
    }
    
    func reflowableViewController(_ rvc: ReflowableViewController!, didHitVideo urlString: String!) {
        print("didHitVideo")
    }
    
    // custom javascript
    func reflowableViewController(_ rvc: ReflowableViewController!, scriptForChapter chapterIndex: Int) -> String! {
        return ""
    }
    
    
    /*
     // SKYEPUB SDK CALLBACKS - not used yet in this project.
     
     func reflowableViewController(_ rvc: ReflowableViewController!, parallelsForTTS chapterIndex: Int32, text: String!) -> NSMutableArray! {
     <#code#>
     }
     
     
    
    
    func reflowableViewController(_ rvc: ReflowableViewController!, didHitLinkForLinearNo urlString: String!) {
        <#code#>
    }
    
    
    
    func reflowableViewController(_ rvc: ReflowableViewController!, didDetectDoubleTapAt position: CGPoint) {
        <#code#>
    }
    
    
    
    func reflowableViewController(_ rvc: ReflowableViewController!, didHitBookmark pageInformation: PageInformation!, isBookmarked: Bool) {
        <#code#>
    }
    
    
    
    func pageTransitionStarted(_ rvc: ReflowableViewController!) {
        <#code#>
    }
    
    func pageTransitionEnded(_ rvc: ReflowableViewController!) {
        <#code#>
    }
    
    
    func reflowableViewController(_ rvc: ReflowableViewController!, styleForChapter chapterIndex: Int) -> String! {
        <#code#>
    }
    

    
    func reflowableViewController(_ rvc: ReflowableViewController!, isBookmarked pageInformation: PageInformation!) -> Bool {
        <#code#>
    }
    

    
    
    func bookmarkImage(_ rvc: ReflowableViewController!, isBookmarked: Bool) -> UIImage! {
        <#code#>
    }
    
    func bookmarkRect(_ rvc: ReflowableViewController!, isBookmarked: Bool) -> CGRect {
        <#code#>
    }
    */
    
    func reflowableViewController(_ rvc: ReflowableViewController!, failedToMove toForward: Bool) {
        //
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}

