import UIKit
import RxSwift

class MovieGridCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var movieImage: UIImageView!
    var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        movieImage.image = nil
        disposeBag = DisposeBag()
    }
    
}
