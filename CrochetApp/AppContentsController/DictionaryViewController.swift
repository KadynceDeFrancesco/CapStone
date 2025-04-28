import UIKit
import AVKit
import AVFoundation

class DictionaryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    struct CrochetTerm {
        let name: String
        let definition: String
        let videoFileName: String
        var isExpanded: Bool = false
    }

    var terms: [CrochetTerm] = [
        CrochetTerm(name: "Applied Slip Stitch Crochet", definition: "With crochet hook, right side facing, and holding yarn under fabric and hook on right side of work, insert hook through fabric, pull up a loop. Insert hook a short distance away, yarn over hook, and pull a new loop up and through loop on hook.", videoFileName: "AppliedSlipStitchCrochet"),
        CrochetTerm(name: "Back Post Double Crochet", definition: "Worked around the post of a stitch from the back; creates a raised effect. Insert hook from back to front to back around the post, complete the double crochet.", videoFileName: "BackPostDoubleCrochet"),
        CrochetTerm(name: "Back Post Single Crochet (BPsc)", definition: "Insert hook from back to front to back around the post of the stitch, yarn over and pull up loop, yarn over and draw through two loops.", videoFileName: "BackPostSingleCrochet"),
        CrochetTerm(name: "Blanket Stitch Crochet", definition: "Decorative edging stitch worked from left to right, often with a needle on knit or crochet fabrics.", videoFileName: "BlanketStitchCrochet"),
        CrochetTerm(name: "Chain (ch)", definition: "Make a slipknot on hook, yarn over, and pull through loop to form a chain. Repeat to create a chain foundation.", videoFileName: "Chain"),
        CrochetTerm(name: "Double Crochet (dc)", definition: "Yarn over, insert hook into stitch, yarn over and pull through (3 loops on hook), yarn over and pull through 2 loops twice.", videoFileName: "DoubleCrochet"),
        CrochetTerm(name: "Double Crochet Four Together (dc4tog)", definition: "Work 4 incomplete double crochets across 4 stitches, leaving the last loop of each on hook, then yarn over and pull through all loops.", videoFileName: "DoubleCrochetFourTogether"),
        CrochetTerm(name: "Double Crochet Three Together (dc3tog)", definition: "Work 3 incomplete double crochets across 3 stitches, leaving loops on hook, then yarn over and pull through all loops.", videoFileName: "DoubleCrochetThreeTogether"),
        CrochetTerm(name: "Double Crochet Two Together (dc2tog)", definition: "Work 2 incomplete double crochets across 2 stitches, leaving loops on hook, then yarn over and pull through all loops.", videoFileName: "DoubleCrochetTwoTogether"),
        CrochetTerm(name: "Double Treble Crochet (dtr)", definition: "Yarn over three times, insert hook, yarn over and pull through two loops four times. Produces a very tall stitch.", videoFileName: "DoubleTrebleCrochet"),
        CrochetTerm(name: "Extended Double Crochet (edc)", definition: "Yarn over, insert hook, yarn over and pull up a loop, yarn over and pull through one loop (extra height), then finish as a double crochet.", videoFileName: "ExtendedDoubleCrochet"),
        CrochetTerm(name: "Extended Single Crochet (esc)", definition: "Insert hook, yarn over and pull up a loop, yarn over and pull through one loop, yarn over and pull through both loops.", videoFileName: "ExtendedSingleCrochet"),
        CrochetTerm(name: "Fasten Off", definition: "Cut yarn, yarn over and pull through final loop to secure work and prevent unraveling.", videoFileName: "FastenOff"),
        CrochetTerm(name: "Foundation Double Crochet (fdc)", definition: "Chain 3 (counts as 1st fdc), yarn over, insert hook in base chain, complete a dc while also forming a foundation chain.", videoFileName: "FoundationDoubleCrochet"),
        CrochetTerm(name: "Foundation Half Double Crochet (fhdc)", definition: "Yarn over, insert hook into base chain, yarn over and pull up loop, yarn over and pull through one loop (foundation), then complete hdc.", videoFileName: "FoundationHalfDoubleCrochet"),
        CrochetTerm(name: "Foundation Single Crochet (fsc)", definition: "Insert hook into base chain, yarn over and pull up loop, yarn over and pull through one loop, yarn over and pull through two loops.", videoFileName: "FoundationSingleCrochet"),
        CrochetTerm(name: "Front Post Double Crochet (FPdc)", definition: "Worked around the front of a post stitch; insert hook from front to back to front and complete a double crochet.", videoFileName: "FrontPostDoubleCrochet"),
        CrochetTerm(name: "Front Post Half Double Crochet (FPhdc)", definition: "Insert hook from front to back to front around the post, yarn over, pull up loop, yarn over and pull through all loops.", videoFileName: "FrontPostHalfDoubleCrochet"),
        CrochetTerm(name: "Front Post Treble Crochet (FPtr)", definition: "Insert hook around front of post, yarn over twice before inserting, then complete as treble crochet.", videoFileName: "FrontPostTrebleCrochet"),
        CrochetTerm(name: "Half Double Crochet (hdc)", definition: "Yarn over, insert hook into stitch, yarn over and pull up loop (3 loops), yarn over and pull through all loops.", videoFileName: "HalfDoubleCrochet"),
        CrochetTerm(name: "Half Double Crochet Three Together (hdc3tog)", definition: "Work 3 hdc stitches partially across 3 stitches, then yarn over and pull through all loops on hook.", videoFileName: "HalfDoubleCrochetThreeTogether"),
        CrochetTerm(name: "Half Post Half Double Crochet (BPhdc)", definition: "Yarn over, insert hook around back of post, yarn over, pull up loop, yarn over and pull through all loops.", videoFileName: "HalfPostHalfDoubleCrochet"),
        CrochetTerm(name: "Magic Ring/Magic Circle", definition: "Form a loop with yarn, work stitches into the loop, then pull yarn tail to close the circle tightly. Used to begin rounds.", videoFileName: "MagicRingMagicCircle"),
        CrochetTerm(name: "Popcorn Stitch", definition: "Work 5 double crochets in same stitch, remove hook from loop, insert hook into first dc, pull working loop through to form 'popcorn'.", videoFileName: "PopcornStitch"),
        CrochetTerm(name: "Reverse Single Crochet (rsc)", definition: "Also called crab stitch. Worked from left to right with single crochet stitches for a twisted, rope-like edge.", videoFileName: "ReverseSingleCrochet"),
        CrochetTerm(name: "Right Side (RS)", definition: "The 'front' or intended outward-facing side of the finished crochet fabric.", videoFileName: "RightSide"),
        CrochetTerm(name: "Shell Stitch", definition: "A group of 5 or more stitches (usually dc) worked into the same stitch or space to create a fan or shell shape.", videoFileName: "ShellStitch"),
        CrochetTerm(name: "Single Crochet (sc)", definition: "Insert hook into stitch, yarn over and pull up loop (2 loops), yarn over and pull through both loops.", videoFileName: "SingleCrochet"),
        CrochetTerm(name: "Single Crochet Four Together (sc4tog)", definition: "Insert hook into 4 consecutive stitches, pull up loop in each (5 loops on hook), yarn over and pull through all loops.", videoFileName: "SingleCrochetFourTogether"),
        CrochetTerm(name: "Single Crochet Three Together (sc3tog)", definition: "Insert hook into 3 stitches, pull up a loop in each, yarn over and pull through all loops.", videoFileName: "SingleCrochetThreeTogether"),
        CrochetTerm(name: "Single Crochet Two Together (sc2tog)", definition: "Insert hook into stitch, pull up loop, insert into next stitch and pull up loop (3 loops), yarn over and pull through all.", videoFileName: "SingleCrochetTwoTogether"),
        CrochetTerm(name: "Skip (sk)", definition: "To leave one or more stitches unworked as instructed in a pattern. Common in mesh or lacework.", videoFileName: "Skip"),
        CrochetTerm(name: "Slip Stitch (sl st)", definition: "Insert hook into stitch, yarn over and pull through both the stitch and the loop on hook. Used to join rounds or move across work.", videoFileName: "SlipStitch"),
        CrochetTerm(name: "Turning Chain (tch)", definition: "Chains made at beginning of a row to bring yarn to correct height. Counts as a stitch in many patterns.", videoFileName: "TurningChain"),
        CrochetTerm(name: "V-Stitch", definition: "Work (dc, ch 1, dc) into the same stitch or space. Forms a V shape and creates a lacy pattern.", videoFileName: "VStitch"),
        CrochetTerm(name: "Wrong Side (WS)", definition: "The 'back' or inside-facing side of the fabric, opposite the Right Side.", videoFileName: "WrongSide"),
        CrochetTerm(name: "Yarn Over (yo)", definition: "Wrap yarn over hook from back to front before inserting it into a stitch or pulling through. A key motion in most stitches.", videoFileName: "YarnOver")
                                    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return terms.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: DictionaryCell.identifier, for: indexPath) as? DictionaryCell else {
            return UITableViewCell()
        }

        let term = terms[indexPath.row]
        cell.stopVideo() // Always stop reused videos
        cell.configure(with: term.name, definition: term.definition, videoFileName: term.videoFileName)
        cell.isExpanded = term.isExpanded
        cell.delegate = self // ✅ Important for Expand button
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        for i in terms.indices {
            if i != indexPath.row, terms[i].isExpanded {
                terms[i].isExpanded = false
                if let otherCell = tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? DictionaryCell {
                    otherCell.stopVideo()
                }
            }
        }

        terms[indexPath.row].isExpanded.toggle()
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

extension DictionaryViewController: DictionaryCellDelegate {
    func expandVideo(player: AVPlayer) {
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.modalPresentationStyle = .fullScreen
        present(playerViewController, animated: true) {
            player.play()
        }
    }
}
