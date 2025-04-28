import UIKit
import AVKit

protocol DictionaryCellDelegate: AnyObject {
    func expandVideo(player: AVPlayer)
}

class DictionaryCell: UITableViewCell {

    static let identifier = "DictionaryCell"

    private let titleLabel = UILabel()
    private let definitionLabel = UILabel()
    private let videoPlayerView = UIView()
    private var buttonStackView: UIStackView!

    private var playButton = UIButton(type: .system)
    private var pauseButton = UIButton(type: .system)
    private var expandButton = UIButton(type: .system)

    private var stackView: UIStackView!

    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?

    weak var delegate: DictionaryCellDelegate?

    var isExpanded: Bool = false {
        didSet {
            definitionLabel.isHidden = !isExpanded
            videoPlayerView.isHidden = !isExpanded
            buttonStackView.isHidden = !isExpanded
            if !isExpanded {
                stopVideo()
            }
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        selectionStyle = .none

        titleLabel.font = UIFont(name: "Impact", size: 20)
        titleLabel.textColor = UIColor(red: 0.584, green: 0.396, blue: 0.706, alpha: 1)


        definitionLabel.font = UIFont.systemFont(ofSize: 16)
        definitionLabel.numberOfLines = 0
        definitionLabel.isHidden = true

        videoPlayerView.backgroundColor = .black
        videoPlayerView.isHidden = true
        videoPlayerView.heightAnchor.constraint(equalToConstant: 200).isActive = true

        playButton.setTitle("Play", for: .normal)
        pauseButton.setTitle("Pause", for: .normal)
        expandButton.setTitle("Expand", for: .normal)

        playButton.addTarget(self, action: #selector(playPressed), for: .touchUpInside)
        pauseButton.addTarget(self, action: #selector(pausePressed), for: .touchUpInside)
        expandButton.addTarget(self, action: #selector(expandPressed), for: .touchUpInside)

        buttonStackView = UIStackView(arrangedSubviews: [playButton, pauseButton, expandButton])
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 10
        buttonStackView.isHidden = true

        stackView = UIStackView(arrangedSubviews: [titleLabel, definitionLabel, videoPlayerView, buttonStackView])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }

    func configure(with term: String, definition: String, videoFileName: String) {
        titleLabel.text = term
        definitionLabel.text = definition

        if player == nil, let path = Bundle.main.path(forResource: videoFileName, ofType: "mp4") {
            let url = URL(fileURLWithPath: path)
            player = AVPlayer(url: url)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.videoGravity = .resizeAspect
            playerLayer?.frame = videoPlayerView.bounds
            if let layer = playerLayer {
                videoPlayerView.layer.addSublayer(layer)
            }
        }
    }

    @objc private func playPressed() {
        player?.play()
    }

    @objc private func pausePressed() {
        player?.pause()
    }

    @objc private func expandPressed() {
        if let player = player {
            delegate?.expandVideo(player: player)
        }
    }

    func playVideo() {
        // No auto-play anymore
    }

    func stopVideo() {
        player?.pause()
        player?.seek(to: .zero)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = videoPlayerView.bounds
    }
}
