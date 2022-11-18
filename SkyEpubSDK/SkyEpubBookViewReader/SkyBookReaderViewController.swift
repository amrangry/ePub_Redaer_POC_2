//
//  BookViewController.swift
//  EpubBookReader
//
//  Created by Amr Elghadban on 04/11/2022.
//

import UIKit

class SkyBookReaderViewController: UIViewController { //swiftlint:disable:this type_body_length file_length
    
    var enableMediaOverlay = true
    //MARK: - Variables In extension usage
    var didApplyClearBox:Bool = false
    //MARK: - Variables
    var bookCode: Int = -1
    var sd: SkyData!
    var info: PageInformation!
    var bookInformation: BookInformation!
    var setting: SkyEpubSetting!
    var rv: ReflowableViewController!
    
    // Informations related to Hightlight/Note UI, Coordinations.
    var currentColor: UIColor!
    var currentHighlight: Highlight!
    var currentStartRect: CGRect!
    var currentEndRect: CGRect!
    var currentMenuFrame: CGRect!
    var isUpArrow: Bool!
    var currentArrowFrame: CGRect!
    var currentArrowFrameForNote: CGRect!
    var currentNoteFrame: CGRect!
    var currentPageInformation: PageInformation = PageInformation()
    
    var isRotationLocked: Bool = false
    var isBookmarked: Bool!
    var lastNumberOfSearched: Int = 0
    var searchScrollHeight: CGFloat = 0
    var searchResults: NSMutableArray = NSMutableArray()
    
    var fontNames: NSMutableArray = NSMutableArray()
    var fontAliases: NSMutableArray = NSMutableArray()
    var selectedFontOffsetY: CGFloat = 0
    var currentSelectedFontIndex: Int = 0
    var currentSelectedFontButton: UIButton!
    
    var themes: NSMutableArray = NSMutableArray()
    var currentTheme: SkyEpubTheme = SkyEpubTheme()
    var currentThemeIndex: Int = 0
    
    var highlights: NSMutableArray   = NSMutableArray()
    var bookmarks: NSMutableArray    = NSMutableArray()
    
    var isAutoPlaying: Bool = true
    var isLoop: Bool = false
    var autoStartPlayingWhenNewChapterLoaded: Bool = false
    var autoMoveChapterWhenParallesFinished: Bool = false
    var currentParallel: Parallel!
    var isChapterJustLoaded: Bool = false
    var isControlsShown: Bool = true
    var isScrollMode: Bool = false
    var isFontBoxMade: Bool = false
    
    var arrow: SkyEpubArrowView!
    
    var snapView: UIView!
    var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - IBOutlet
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
    
    //MARK: - LifeCycle
    
    // entry point of view controller.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ad = SkyConfigurator.shared//UIApplication.shared.delegate as? AppDelegate
        sd = ad.data
        
        setting = sd.fetchSetting()
        setting.mediaOverlay = enableMediaOverlay
        
        makeThemes()
        
        currentThemeIndex = setting.theme
        currentThemeIndex = 0
        currentTheme = themes.object(at: currentThemeIndex) as! SkyEpubTheme
        
        self.addSkyErrorNotificationObserver()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didRotate), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        self.makeBookViewer()
        self.makeUI()
        self.recalcPageLabels()
        
        currentColor = self.getMarkerColor(colorIndex: 0)
        
        let markerImage = self.getMakerImageFromColor(color: UIColor.yellow)
        isAutoPlaying = true
        autoStartPlayingWhenNewChapterLoaded = setting.autoStartPlaying
        autoMoveChapterWhenParallesFinished  = setting.autoLoadNewChapter
        isLoop = false
        // Do any additional setup after loading the view.
    }
    
    /// this destory function should be called whenever is is dismissed.
    func destroy() {
        NotificationCenter.default.removeObserver(self)
        self.removeSkyErrorNotification()
        sd.updateBookPosition(bookInformation:self.bookInformation)
        sd.updateSetting(setting:setting)
        self.bookInformation = nil
        rv.dataSource = nil
        rv.delegate = nil
        //        rv.customView = nil
        rv.removeFromParent()
        rv.view.removeFromSuperview()
        rv.destroy()
    }
    
    override func dismiss(animated flag: Bool,
                          completion: (() -> Void)?) {
        super.dismiss(animated: flag, completion: completion)
        NSLog("Dismissed")
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
    
    //MARK: - IBAction
    @IBAction func homePressed(_ sender: Any) {
        destroy()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func brightnessSliderChanged(_ sender: Any) {
        setting.brightness = Double((sender as! UISlider).value)
        UIScreen.main.brightness = CGFloat(setting.brightness)
    }
    
    @IBAction func trashPressed(_ sender: Any) {
        rv.deleteHightlight(currentHighlight)
        hideHighlightBox()
    }
    
    @IBAction func savePressed(_ sender: Any) {
        hideHighlightBox()
    }
    
    //MARK: - Helper
    func getBookPath()->String {
        let bookPath: String = "\(rv.baseDirectory!)/\(rv.fileName!)"
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
        // rv.setTTSLanguage("auto")
        rv.setTTSLanguage("sa_ar")
        // set the voice rate (voice speed) of mediaOverlay (1.0f is default, if 2.0 is set, twice times faster than normal speed.
        rv.setMediaOverlayRate(1.0)
        // disable scroll mode.
        rv.setScrollMode(false)
        // set License Key for Reflowable Layout
        rv.setLicenseKey("0000-0000-0000-0000")
        // make SkyProvider object to read epub reader.
        let skyProvider: SkyProvider = SkyProvider()
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
    
    // make user interface.
    func makeUI() {
        // if RTL (Right to Left writing like Arabic or Hebrew)
        if rv.isRTL() {
            // Inverse the direction of slider.
            slider.transform = slider.transform.rotated(by: CGFloat(180.0/180*3.141592))
        }
        if rv.isGlobalPagination() {
            slider.maximumValue = Float(rv.getNumberOfPagesInBook()-1)
            slider.minimumValue = 0
            let globalPageIndex = rv.getPageIndexInBook()
            slider.value = Float(globalPageIndex)
        }
        isRotationLocked = setting.lockRotation
        self.makeFonts()
        arrow = SkyEpubArrowView()
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
    
    // display proper ui controls for rotation and direction.
    func recalcPageLabels() {
        if self.isPortrait() {
            pageIndexLabel.isHidden = false
            leftIndexLabel.isHidden = true
            rightIndexLabel.isHidden = true
        } else {
            if setting.doublePaged {
                pageIndexLabel.isHidden = true
                leftIndexLabel.isHidden = false
                rightIndexLabel.isHidden = false
            } else {
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
    
    // display page number or index.
    func changePageLabels(pageInformation:PageInformation) {
        var pi,pn:Int
        if rv.isGlobalPagination() {
            pi = pageInformation.pageIndexInBook
            pn = pageInformation.numberOfPagesInBook
        } else {
            pi = pageInformation.pageIndex
            pn = pageInformation.numberOfPagesInChapter
        }
        var dpi,dpn:Int
        if rv.isDoublePaged() && !self.isPortrait() {
            dpi = (pi*2)+1
            dpn = pn*2
            leftIndexLabel.text = "\(dpi)/\(dpn)"
            dpi = (pi*2)+2
            rightIndexLabel.text = "\(dpi)/\(dpn)"
        } else {
            dpi = pi+1
            dpn = pn
            pageIndexLabel.text = "\(dpi)/\(dpn)"
        }
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
                menuX = (endRect.size.width-menuBox.frame.size.width)/2+endRect.origin.x
                arrowX = (endRect.size.width-arrowWidth)/2+endRect.origin.x
                isUpArrow = true
                currentMenuFrame = CGRect(x:menuX,y:endRect.origin.y+endRect.size.height+70,width:menuBox.bounds.size.width,height:menuBox.bounds.size.height)
            }
        } else {
            arrowX = (startRect.size.width-arrowWidth)/2+startRect.origin.x
            menuX = (startRect.size.width-menuBox.frame.size.width)/2+startRect.origin.x
            currentMenuFrame = CGRect(x:menuX,y:startRect.origin.y-topAdjust,width:menuBox.bounds.size.width,height:menuBox.bounds.size.height)
            isUpArrow = false
        }
        
        if (currentMenuFrame.origin.x < self.view.bounds.size.width*0.1) {
            currentMenuFrame.origin.x = self.view.bounds.size.width*0.1
        } else if ((currentMenuFrame.origin.x + currentMenuFrame.size.width) > self.view.bounds.size.width*0.9) {
            currentMenuFrame.origin.x = self.view.bounds.size.width*0.9-currentMenuFrame.size.width
        }
        
        if (arrowX < currentMenuFrame.origin.x+20) {
            arrowX = currentMenuFrame.origin.x+20
        }
        if (arrowX > currentMenuFrame.origin.x + menuBox.bounds.size.width-40) {
            arrowX = currentMenuFrame.origin.x+menuBox.bounds.size.width-40
        }
        if (isUpArrow) {
            currentArrowFrame = CGRect(x:arrowX,y:currentMenuFrame.origin.y-arrowHeight+4,width:arrowWidth,height:arrowHeight)
        } else {
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
        } else if targetType==1 {
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
    
    func isPad() ->Bool {
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad)  {
            return true
        } else {
            return false
        }
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
            slider.minimumValue = 0
            
            let globalPageIndex = rv.getPageIndexInBook()
            slider.value = Float(globalPageIndex)
        }
        let pg = PageInformation()
        pg.pageIndexInBook = Int(rv.getPageIndexInBook())
        pg.numberOfPagesInBook = Int(rv.getNumberOfPagesInBook())
        self.changePageLabels(pageInformation : pg)
        self.recalcPageLabels()
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
        } else {
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
    
    
    
    func showTableView(index:Int) {
        contentsTableView.isHidden = true
        notesTableView.isHidden = true
        bookmarksTableView.isHidden = true
        if (index==0) {
            contentsTableView.isHidden = false
        } else if (index==1) {
            notesTableView.isHidden = false
        } else if (index==2) {
            bookmarksTableView.isHidden = false
        }
    }
    
    func reloadContents() {
        //        if !isContentsTableViewLoaded {
        contentsTableView.reloadData()
        //            isContentsTableViewLoaded = true
        //        }
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
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}

