import SwiftUI
import UIKit

struct QRCodeScannerRepresentable: UIViewControllerRepresentable {
    var onQRCodeScanned: (String) -> Void
    var onError: (String) -> Void
    
    func makeUIViewController(context: Context) -> QRCodeScannerViewController {
        let controller = QRCodeScannerViewController()
        controller.onQRCodeScanned = onQRCodeScanned
        controller.onError = onError
        return controller
    }
    
    func updateUIViewController(_ uiViewController: QRCodeScannerViewController, context: Context) {
    }
}

