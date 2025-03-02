import UIKit

class DictionaryViewController: UITableViewController {
    
    struct CrochetTerm {
        let title: String
        let definition: String
        let description: String
        var isExpanded: Bool
    }
    
    var terms: [CrochetTerm] = [
        CrochetTerm(title: "Half Double Crochet", definition: "A half double crochet is...", description: "Insert hook, yarn over...", isExpanded: false),
        CrochetTerm(title: "Treble Crochet", definition: "A treble crochet is...", description: "Yarn over twice...", isExpanded: false)
    ]
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return terms.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return terms[section].isExpanded ? 2 : 1 // Title + Details if expanded
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let term = terms[indexPath.section]
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath)
            cell.textLabel?.text = term.title
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
            cell.textLabel?.text = "\(term.definition)\n\n\(term.description)"
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            terms[indexPath.section].isExpanded.toggle()
            tableView.reloadSections([indexPath.section], with: .automatic)
        }
    }
}
