//
//  MultipleImagesViewController.swift
//  Pods

import UIKit
import AVFoundation
import Photos

public typealias MultipleImageCameraViewCompletion = ([Images]?) -> Void

public class MultipleImagesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // Images to put in array
    var picLargeImage: UIImage?
    var picThumbImage: UIImage?
    // Collection view
    var picThumbSize: CGFloat = 72
    var picLargeSize: CGFloat = 480
    let multipleImagesCellIdentifier = "MultipleImagesCollectionViewCell"
    static let defaultHeightCollectionView: CGFloat = 80
    static let ratioOfParcelImage: CGFloat = 1
    static let cellsSpacing: CGFloat = 6

    // Outlet
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var constraintHeightCollectionVw: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var cameraView: CameraView!

    //completion block
    var onCompletion: MultipleImageCameraViewCompletion?

    // Variables
    var allowCropping = false
    var maximumImages = 1
    var minimumImages = 1

    // array
//    var arrSelectedImages: [UIImage] = []
    var arrSelectedImages: [Images] = []

    public init(croppingEnabled: Bool, maxNumOfImages: Int, minNumOfImages: Int, thumbSize: CGFloat, largeSize: CGFloat, completion: @escaping MultipleImageCameraViewCompletion) {
        super.init(nibName: "MultipleImageCameraViewController", bundle: Bundle(for: MultipleImagesViewController.self))
        onCompletion = completion
        picThumbSize = thumbSize
        picLargeSize = largeSize
        maximumImages = maxNumOfImages
        minimumImages = minNumOfImages
        allowCropping = croppingEnabled

    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public override var prefersStatusBarHidden: Bool {
        return true
    }

    public override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }

    /**
     * Configure the background of the superview to black
     * and add the views on this superview. Then, request
     * the update of constraints for this superview.
     */
    public override func loadView() {
        super.loadView()
        view.backgroundColor = UIColor.black
        view.setNeedsUpdateConstraints()
    }

    /**
     * Add observer to check when the camera has started,
     * enable the volume buttons to take the picture,
     * configure the actions of the buttons on the screen,
     * check the permissions of access of the camera and
     * the photo library.
     * Configure the camera focus when the application
     * start, to avoid any bluried image.
     */
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        addCameraObserver()
        addRotateObserver()
        setupActions()
        checkPermissions()
        cameraView.configureFocus()
        toggleNextButton()
        toggleCollectionViewHeight()
    }

    /**
     * Start the session of the camera.
     */
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraView.startSession()
    }

    /**
     * Enable the button to take the picture when the
     * camera is ready.
     */
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if cameraView.session?.isRunning == true {
            notifyCameraReady()
        }
    }

    /**
     * Observer the camera status, when it is ready,
     * it calls the method cameraReady to enable the
     * button to take the picture.
     */
    private func addCameraObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(notifyCameraReady),
            name: NSNotification.Name.AVCaptureSessionDidStartRunning,
            object: nil)
    }

    /**
     * Observer the device orientation to update the
     * orientation of CameraView.
     */
    private func addRotateObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(rotateCameraView), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)

//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(rotateCameraView),
//            name: NSNotification.Name.UIDevice.orientationDidChangeNotification,
//            object: nil)
    }

    @objc internal func notifyCameraReady() {
        cameraButton.isEnabled = true
    }

    /**
     * Configure the action for every button on this
     * layout.
     */
    private func setupActions() {
        cameraButton.action = { [weak self] in self?.capturePhoto() }
        closeButton.action = { [weak self] in self?.close() }
        nextButton.action = { [weak self] in self?.next() }
    }

    /**
     * Toggle the buttons status, based on the actual
     * state of the camera.
     */
    private func toggleButtons(enabled: Bool) {
        [cameraButton,
         closeButton,
         nextButton].forEach({ $0.isEnabled = enabled })
    }

    /**
     * Toggle next button status, based on the number of images selected so far.
     */
    private func toggleNextButton() {
        if arrSelectedImages.count < minimumImages { nextButton.isEnabled = false } else {
            nextButton.isEnabled = true
        }
    }
    /**
     * Toggle collection View Height, based on the number of images selected so far.
     */
    private func toggleCollectionViewHeight() {
        if arrSelectedImages.count == 0 { constraintHeightCollectionVw.constant = 0 } else {
            constraintHeightCollectionVw.constant = MultipleImagesViewController.defaultHeightCollectionView
        }
    }

    @objc func rotateCameraView() {
        cameraView.rotatePreview()
    }

    /**
     * Validate the permissions of the camera and
     * library, if the user do not accept these
     * permissions, it shows an view that notifies
     * the user that it not allow the permissions.
     */
    internal func checkPermissions() {
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) != .authorized {
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
                DispatchQueue.main.async {
                    if !granted {
                        self.showNoPermissionsView()
                    }
                }
            }
        }
    }

    /**
     * Generate the view of no permission.
     */
    private func showNoPermissionsView(library: Bool = false) {
        self.view.layoutIfNeeded()
        let permissionsView = PermissionsView(frame: UIScreen.main.bounds)
        permissionsView.layoutIfNeeded()
        let title: String
        let desc: String

        if library {
            title = localizedString("permissions.library.title")
            desc = localizedString("permissions.library.description")
        } else {
            title = localizedString("permissions.title")
            desc = localizedString("permissions.description")
        }

        permissionsView.configureInView(view, title: title, descriptiom: desc, completion: close)
         permissionsView.layoutIfNeeded()
    }

    /**
     * This method will be called when the user
     * try to take the picture.
     * It will lock any button while the shot is
     * taken, then, realease the buttons and save
     * the picture on the device.
     */
    internal func capturePhoto() {

        if arrSelectedImages.count >= maximumImages {
//            AppUtility.showAlert("", message: localizedString("error.click-images"), delegate: self, cancelButtonTitle: "Ok".localized)
            return
        }

        guard let output = cameraView.imageOutput,
            let connection = output.connection(with: AVMediaType.video) else {
                return
        }

        if connection.isEnabled {
            toggleButtons(enabled: false)
            cameraView.capturePhoto { image in
                guard let image = image else {
                    self.toggleButtons(enabled: true)
                    return
                }
                self.saveImage(image: image)
            }
        }
    }

    internal func saveImage(image: UIImage) {
        _ = SingleImageSaver()
            .setImage(image)
            .onSuccess { asset in
                self.layoutCameraResult(asset: asset)
            }
            .onFailure { _ in
                self.toggleButtons(enabled: true)
                self.showNoPermissionsView(library: true)
            }
            .save()
    }

    internal func close() {
        onCompletion?(nil)
    }

    internal func next() {
        if arrSelectedImages.count < minimumImages {

        } else {
            onCompletion?(arrSelectedImages)
        }
    }

    internal func layoutCameraResult(asset: PHAsset) {
        cameraView.stopSession()
        startConfirmController(asset: asset)
        toggleButtons(enabled: true)
    }

    private func startConfirmController(asset: PHAsset) {
        let confirmViewController = ConfirmViewController(asset: asset, allowsCropping: allowCropping)
        confirmViewController.onComplete = { image, asset in
            if let image = image, let assetValue = asset {
                self.resizeImage(pickedImage: image)
                if let thumbImage = self.picThumbImage, let image = self.picLargeImage {
                    let image = self.putDataInModel(assetValue: assetValue, thumb: thumbImage, fullImage: image)
                     self.arrSelectedImages.append(image)
                }
                self.collectionView.reloadData()
                self.toggleNextButton()
                self.toggleCollectionViewHeight()
            }
            self.dismiss(animated: true, completion: nil)
        }
        confirmViewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        present(confirmViewController, animated: true, completion: nil)
    }

    //collection view methods

    // MARK: CollectionView delegate & data source

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrSelectedImages.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.register(UINib(nibName: "MultipleImageCollectionViewCell", bundle: Bundle(for: MultipleImagesCollectionViewCell.self)), forCellWithReuseIdentifier: multipleImagesCellIdentifier)
        guard let cell: MultipleImagesCollectionViewCell = (collectionView.dequeueReusableCell(withReuseIdentifier: multipleImagesCellIdentifier, for: indexPath as IndexPath) as? MultipleImagesCollectionViewCell), self.arrSelectedImages.isArrayIndexWithinBound(index: indexPath.row) else {
            return UICollectionViewCell()
        }
        let imageObj = self.arrSelectedImages[indexPath.row]
        guard let imgThumb = imageObj.thumbImage else {
            return UICollectionViewCell()
        }
        cell.setContentOnCell(imageParcel: imgThumb)

        cell.btnCancelImageTapped = { [unowned self] (selectedCell) -> Void in
            let path = collectionView.indexPathForItem(at: selectedCell.center)!
            self.arrSelectedImages.remove(at: path.row)
            self.toggleCollectionViewHeight()
            self.collectionView.reloadData()
            self.toggleNextButton()
        }
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: (self.collectionView.frame.size.width / CGFloat(maximumImages)) - MultipleImagesViewController.cellsSpacing, height: ((self.collectionView.frame.size.width / CGFloat(maximumImages)) - MultipleImagesViewController.cellsSpacing)/MultipleImagesViewController.ratioOfParcelImage)
        return size
    }

}
