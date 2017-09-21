//
//  WishCollectionViewController.swift
//  birthday-wishes
//
//  Created by Morten Saabye Kristensen on 13/09/2017.
//  Copyright © 2017 Morten Saabye Kristensen. All rights reserved.
//

import UIKit
import os.log

class WishCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
//    MARK: Properties
    var wishes = [[Wish]]()
    private var reuseIdentifier = "WishCell"
    
//    MARK: ViewController overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        let wishArray = loadSampleWishes()
        wishes = sortWishes(wishes: wishArray)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        collectionViewLayout.invalidateLayout()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "editWish" {
            guard let navController = segue.destination as? UINavigationController else {
                os_log("Could not cast to NavController", log: OSLog.default, type: .debug)
                return
            }
            guard let destinationViewController = navController.topViewController as? WishViewController else {
                os_log("Could not cast to Wish WishViewController", log: OSLog.default, type: .debug)
                return
            }
            guard let selectedCell = sender as? WishCollectionViewCell else {
                os_log("Could not cast to Wish CollectionViewCell", log: OSLog.default, type: .debug)
                return
            }
            guard let indexPath = collectionView?.indexPath(for: selectedCell) else {
                os_log("Could not find indexPath of selectedcell", log: OSLog.default, type: .debug)
                return
            }
            destinationViewController.wish = wishes[indexPath.section][indexPath.row]
        }
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    
    
//    MARK: Actions
    fileprivate func extractedFunc(_ wish: Wish) {
        if let selectedIndexPath = collectionView?.indexPathsForSelectedItems?.first {
            //            if an item has been edited, use this block
            if Wish.categories[selectedIndexPath.section] != wish.category {
                //                If the category was changed, the collectionView and the datasource need to be rearranged.
                guard let newSection = Wish.categories.index(of: wish.category) else {
                    fatalError("Category doesn't exist")
                }
                //                If a new category has been created, insert an array in datasource and a section in collectionView
                if Wish.categories.count > wishes.count {
                    wishes.append([Wish]())
                    let index = IndexSet(integer: newSection)
                    collectionView?.insertSections(index)
                }
                //                Find new position for item
                let newRow = wishes[newSection].count
                let newIndexPath = IndexPath(row: newRow, section: newSection)
                //                Move item to new position
                wishes[selectedIndexPath.section].remove(at: selectedIndexPath.row)
                wishes[newSection].append(wish)
                collectionView?.moveItem(at: selectedIndexPath, to: newIndexPath)
                //                If the section is now empty, remove the section.
                if wishes[selectedIndexPath.section].count == 0 && Wish.categories[selectedIndexPath.section] != "Other" {
                    wishes.remove(at: selectedIndexPath.section)
                    let index = IndexSet(integer: selectedIndexPath.section)
                    Wish.categories.remove(at: selectedIndexPath.section)
                    collectionView?.deleteSections(index)
                }
            } else {
                //                If the item changed, but not the category. Only updates to the object need to made
                wishes[selectedIndexPath.section][selectedIndexPath.row] = wish
                collectionView?.reloadItems(at: [selectedIndexPath])
            }
            
        } else {
            //            if its a new item, use this block
            if wishes.isEmpty == true {
                wishes.append([Wish]())
                collectionView?.reloadSections(IndexSet(integer: 0))
            }
            let categoryToFind = wish.category
            var section = 0
            //            Find out which section the item belongs in
            for category in Wish.categories {
                if categoryToFind == category {
                    break
                }
                //                If no category is found, it's because a new section has been made.
                section = section + 1
            }
            if wishes.count < Wish.categories.count {
                wishes.append([Wish]())
                section = wishes.count - 1
                let index = IndexSet(integer: section)
                collectionView?.insertSections(index)
            }
            let indexPath = IndexPath(row: wishes[section].count, section: section)
            wishes[section].append(wish)
            collectionView?.insertItems(at: [indexPath])
        }
    }
    
    @IBAction func unwindFromCreateView(sender: UIStoryboardSegue) {
        guard let sourceViewController = sender.source as? WishViewController, let wish = sourceViewController.wish else {
            fatalError("Could not cast as WishViewController")
        }
        extractedFunc(wish)
    }
    

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return Wish.categories.count
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if wishes.isEmpty == true {
            return 0
        } else {
            return wishes[section].count
        }
        
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? WishCollectionViewCell else {
            fatalError("Could not cast")
        }
        
        // Configure the cell
        let wish = wishes[indexPath.section][indexPath.row]
        cell.contentView.layer.cornerRadius = 5
        cell.contentView.layer.masksToBounds = true
        cell.layer.masksToBounds = false
        cell.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.layer.shadowRadius = 2;
        cell.layer.shadowOpacity = 0.2;
        cell.WishTitle.text = wish.title
        cell.WishThumbNail.image = wish.image
        return cell
        
    }
    
    // MARK: UICollectionViewDelegate
    

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as?SectionHeaderCollectionReusableView else {
            fatalError("Could not cast reusable view to header")
        }
        if wishes.isEmpty == true {
            headerView.sectionHeaderLabel.text = "No wishes to show"
        } else {
            headerView.sectionHeaderLabel.text = Wish.categories[indexPath.section]
        }
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if wishes.count != 0 {
            presentActionSheetForItem(at: indexPath)
        }
    }
//    MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.bounds.size.width / 2) - 16
        
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    
//    MARK: Private methods
    private func loadSampleWishes() -> [Wish]{
        var samples = [Wish]()
//        let wish1 = Wish(title: "Philips Dampstrygejern GC4527/00 Azur performer Plus - 2600 W", url: URL(fileURLWithPath: "https://www.proshop.dk/Strygning/Philips-Dampstrygejern-GC452700-Azur-performer-Plus-2600-W/2577208?cid=e6d1c1ca-8d90-4e30-a415-b908d9a25a97"), photo: #imageLiteral(resourceName: "iron"), category: "Practical Stuff")
//        let wish2 = Wish(title: "AL-KO Benzinplæneklipper Highline 51.5 SP-A", url: URL(fileURLWithPath: "https://www.proshop.dk/Plaeneklipper/AL-KO-Benzinplaeneklipper-Highline-515-SP-A/2563619?cid=fe2a657a-ba40-4a6c-b4cd-08ad4085d9a3"), photo: #imageLiteral(resourceName: "mower"), category: "Machines")
//        let wish3 = Wish(title: "Canon PGI-570/CLI-571 PGBK/BK/C/M/Y Multi Pack - Blækpatron Sort", url: URL(fileURLWithPath: "https://www.proshop.dk/Blaek-Toner-Forbrugsstoffer/Canon-PGI-570CLI-571-PGBKBKCMY-Multi-Pack-Blaekpatron-Sort-/2532133"), photo: #imageLiteral(resourceName: "ink"))
//        samples.append(wish1)
//        samples.append(wish2)
//        samples.append(wish3)
        return samples
    }
    
    private func presentActionSheetForItem(at indexPath: IndexPath){
        let alert = UIAlertController(title: "Choose an action", message: "Do something with the selected wish", preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: "Edit", style: .default, handler: {_ in self.performSegue(withIdentifier: "editWish", sender: self.collectionView?.cellForItem(at: indexPath))})
        let action2 = UIAlertAction(title: "Delete", style: .destructive, handler: {_ in self.deleteItem(at: indexPath)})
        let action3 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(action3)
        present(alert, animated: true, completion: nil)
    }
    
    private func deleteItem(at indexPath: IndexPath) {
        wishes[indexPath.section].remove(at: indexPath.row)
        if wishes[indexPath.section].count == 0 && Wish.categories[indexPath.section] != "Other" {
            wishes.remove(at: indexPath.section)
            let index = IndexSet(integer: indexPath.section)
            Wish.categories.remove(at: indexPath.section)
            collectionView?.deleteSections(index)
        } else {
            collectionView?.deleteItems(at: [indexPath])
        }
        collectionView?.reloadData()
    }
    
    private func sortWishes(wishes: [Wish]) -> [[Wish]] {
        var sortedInDictionary = [String: [Wish]]()
        wishes.forEach { (wish) in
            let category = wish.category
            if sortedInDictionary[category] == nil {
                sortedInDictionary[category] = [wish]
            } else {
                sortedInDictionary[category]?.append(wish)
            }
        }
        let categories = Wish.categories
        var sortedWishes = [[Wish]]()
        categories.forEach { (category) in
            if let categoryArray = sortedInDictionary[category] {
                sortedWishes.append(categoryArray)
            }
        }
        return sortedWishes
    }
}
