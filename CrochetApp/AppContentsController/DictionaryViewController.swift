import UIKit
import SwiftUI


struct DictionaryTerm {
    let name: String
    let definition: String
    let description: String
    let videoName: String?
    var isExpanded: Bool = false
}

class DictionaryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var terms: [DictionaryTerm] = [
        DictionaryTerm(name: "Treble Crochet (tr)", definition: "A taller stitch than a double crochet, creating a looser fabric.", description: "", videoName: nil),
        DictionaryTerm(name: "Double Crochet (dc)", definition: "A common crochet stitch that is twice as tall as a single crochet.", description: "", videoName: nil),
        DictionaryTerm(name: "Single Crochet (sc)", definition: "A basic crochet stitch that creates a tight, dense fabric.", description: "", videoName: nil),
        DictionaryTerm(name: "Half Double Crochet (hdc)", definition: "A stitch taller than a single crochet but shorter than a double crochet.", description: "", videoName: nil),
        DictionaryTerm(name: "Applied Slip Stitch Crochet", definition: "With crochet hook, right side facing, and holding yarn under fabric and hook on right side of work, insert hook through fabric, pull up a loop.", description: "", videoName: nil),
        DictionaryTerm(name: "Back Post Double Crochet (BPHdc)", definition: "A common crochet stitch that is twice as tall as a single crochet.", description: "", videoName: nil),
        DictionaryTerm(name: "Blanket Stitch Crochet", definition: "This stitch, worked from left to right, is great for edging a knitted garment or blanket. Bring threaded needle out from back to front at the center of a knitted stitch. *Insert needle at center of next stitch to the right and two rows up, and out at the center of the stitch two rows below. Repeat from *.", description: "", videoName: nil),
        DictionaryTerm(name: "Chain (ch)", definition: "A crochet chain can be used for all sorts of reasons in a pattern but most often it is used as the starting place for a crochet project. In this case it is known as your foundation chain. Here’s how to make a crochet chain:Make a slipknot on hook, *yarn over and draw through loop of slipknot; repeat from * drawing yarn through last loop formed.", description: "", videoName: nil),
        DictionaryTerm(name: "Double Crochet Four Together (dc4tog)", definition: "[Yarn over, insert hook in indicated stitch or space, yarn over and pull up loop, yarn over and draw through 2 loops] 4 times (5 loops on hook), yarn over, draw through all loops on hook—3 stitches decreased.", description: "", videoName: nil),
        DictionaryTerm(name: "Double Crochet Two Together (dc2tog)", definition: "A basic crochet stitch that creates a tight, dense fabric.", description: "", videoName: nil),
        DictionaryTerm(name: "Half Double Crochet", definition: "Yarn over, insert hook in indicated stitch or space, yarn over (Figure 1) and pull up loop, yarn over (Figure 2), draw through 2 loops] 2 times (3 loops on hook), yarn over (Figure 3), draw through all loops on hook—1 stitch decreased ", description: "", videoName: nil),
        DictionaryTerm(name: "Double Crochet Three Together (dc3tog)", definition: "[Yarn over, insert hook in indicated stitch or space, yarn over and pull up loop (Figure 1), yarn over, draw through 2 loops (Figure 2)] 3 times (4 loops on hook), yarn over, draw through all loops on hook (Figure 3)—2 stitches decreased (Figure 4).", description: "", videoName: nil),
        DictionaryTerm(name: "Double Treble Crochet (dtc)", definition: "A common crochet stitch that is twice as tall as a single crochet.", description: "Yarn over three times and insert hook in 6th chain from hook. Draw a loop through chain—5 loops on hook; [yarn over and draw through 2 loops] 4 times.", videoName: nil),
        DictionaryTerm(name: "Extended Double Crochet (edc)", definition: "Yarn over, insert hook in next stitch or chain, yarn over and pull up loop (3 loops on hook), yarn over and draw through 1 loop (1 chain made), [yarn over and draw through 2 loops] 2 times—1 edc completed.", description: "", videoName: nil),
        DictionaryTerm(name: "Extended Single Crochet (esc)", definition: "Insert hook in next stitch or chain, yarn over and pull up loop (2 loops on hook), yarn over and draw through 1 loop (1 chain made), yarn over and pull through 2 loops—1 esc completed.", description: "", videoName: nil),
        DictionaryTerm(name: "Foundation Double Crochet (fdc)", definition: "Chain 3. Yarn over, insert hook in 3rd chain from hook, yarn over and pull up loop (3 loops on hook) (Figure 1), yarn over and draw through 1 loop (1 chain made—shaded) (Figure 2), (yarn over and draw through 2 loops—Figure 3) 2 times—1 foundation double crochet with chain at bottom (Figure 4). *Yarn over, insert hook under the 2 loops of the chain at the bottom of the stitch just made, yarn over and pull up loop (3 loops on hook) (Figure 5), yarn over and draw through 1 loop (1 chain made), (yarn over and draw through 2 loops) 2 times (Figure 6). Repeat from *.", description: "", videoName: nil),
        DictionaryTerm(name: "Foundation Half Double Crochet (fhdc)", definition: "Chain 3, yarn over, insert hook in 3rd chain from hook, yarn over and pull up loop (3 loops on hook), yarn over and draw through 1 loop (1 chain made), yarn over and draw through all loops on hook—1 foundation half double crochet. *Yarn over, insert hook under the 2 loops of the “chain” stitch of last stitch and pull up loop, yarn over and draw through 1 loop, yarn over and draw through all loops on hook; repeat from *.", description: "", videoName: nil),
        DictionaryTerm(name: "Foundation Single Crochet (fsc)", definition: "Chain 2 (Figure 1), insert hook in 2nd chain from hook, yarn over and pull up loop (2 loops on hook), yarn over, draw through 1 loop (1 chain made), yarn over and draw through 2 loops (single crochet)—1 foundation single crochet with chain at bottom (Figure 3). *Insert hook under the 2 loops of the chain at the bottom of the stitch just made, yarn over and pull up loop, yarn over and draw through 1 loop, yarn over and draw through 2 loops. Repeat from * (Figure 5).", description: "", videoName: nil),
        DictionaryTerm(name: "Front Post Double Crochet (FPdc)", definition: "Yarn over 2 times, insert hook from front to back to front around post of indicated stitch, yarn over and pull up loop, [yarn over, draw through 2 loops on hook] 3 times.", description: "", videoName: nil),
        DictionaryTerm(name: "Half Double Crochet Two Together (hdc2tog)", definition: "[Yarn over, insert hook in indicated stitch or space, yarn over (Figure 1) and pull up loop (Figure 2)] 3 times, yarn over and draw through all loops on hook (Figure 3)—2 stitches decreased (Figure 4).", description:"", videoName: nil),
        DictionaryTerm(name: "Half Double Crochet Three Together (hdc3tog)", definition: "Yarn over, insert hook from front to back to front around post of indicated stitch, yarn over and pull up loop, yarn over and draw through all loops on hook.", description:"", videoName: nil),
        DictionaryTerm(name: "Front Post Half Double Crochet (fphdc)", definition: "Yarn over, insert hook from front to back to front around post of indicated stitch, yarn over and pull up loop, yarn over and draw through all loops on hook.", description:"", videoName: nil),
    ]
    
    var filteredTerms: [DictionaryTerm] = []
      var isFiltering = false

      override func viewDidLoad() {
          super.viewDidLoad()
          
          tableView.delegate = self
          tableView.dataSource = self
          searchBar.delegate = self

          
          filteredTerms = terms  // Default to showing all terms
      }

      // MARK: - TableView DataSource
      
      func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return filteredTerms.count
      }

      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCell(withIdentifier: "DictionaryCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "DictionaryCell")
          let term = filteredTerms[indexPath.row]
          
          cell.textLabel?.text = term.name
          cell.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
          cell.textLabel?.textColor = .systemBlue
          
          cell.detailTextLabel?.text = term.isExpanded ? term.definition : ""
          cell.detailTextLabel?.numberOfLines = term.isExpanded ? 0 : 1
          
          return cell
      }


      // MARK: - TableView Delegate
      
      func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
          tableView.deselectRow(at: indexPath, animated: true)
          
          // Toggle expansion
          filteredTerms[indexPath.row].isExpanded.toggle()
          
          // Smooth animation
          tableView.beginUpdates()
          tableView.reloadRows(at: [indexPath], with: .automatic)
          tableView.endUpdates()
      }

      // MARK: - Search Bar Functionality
      
      func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
          if searchText.isEmpty {
              isFiltering = false
              filteredTerms = terms
          } else {
              isFiltering = true
              filteredTerms = terms.filter { $0.name.lowercased().contains(searchText.lowercased()) }
          }
          tableView.reloadData()
      }
  }
