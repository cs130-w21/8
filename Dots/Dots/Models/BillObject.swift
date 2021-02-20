//
//  Bill.swift
//  Dots
//
//  Created by Jack Zhao on 1/9/21.
//

import Foundation

// MARK: Create a BillObject

/// represents a single bill.
struct BillObject: Identifiable, Codable, Equatable {
    static func == (lhs: BillObject, rhs: BillObject) -> Bool {
        return lhs.id == rhs.id
    }
    
    
    /// id of the bill
    let id: UUID
    
    /// a String representing the title of the bill
    var title: String
    
    /// date of the bill
    var date: Date
    
    /// a list of Ints representing the participants of the bill
    var attendees: [Int]
    
    /// an Int representing the member who paid for the bill
    var initiator: Int  // This number must be contained by attendees
    
    /// a Boolean indicating whether the bill has been paid or not
    var paid: Bool
    
    /// a Double representing the taxRate of the items in the bill
    var taxRate: Double
    var billAmount: Double /* Depricated, no longer in use. Use self.getBillTotal() instead */
    
    /// a list of EntryObject representing the item entries of the bill
    var entries: [EntryObject]
    
    
    /// initialize a BillObject.
    /// - Parameters:
    ///   - id: id of the bill
    ///   - title: a String representing the title of the bill
    ///   - date: date of the bill
    ///   - attendees: a list of Ints representing the attendees/participants of the bill; default empty
    ///   - initiator: an Int representing the initiator of the bill
    ///   - paid: a Boolean representing whether the bill is paid or not; default False
    ///   - tax: a Double representing the tax rate of the item entries of the bill; default 0
    ///   - billAmount: <#billAmount description#>
    ///   - entries: a list of EntryObject representing the entries of the bill; default empty
    init(id: UUID = UUID(), title: String = "", date: Date = Date(), attendees: [Int] = [], initiator: Int = -1, paid: Bool = false, tax: Double = 0.0, billAmount: Double = 0.0, entries: [EntryObject] = []) {
        self.id = id
        self.title = title
        self.date = date
        self.attendees = attendees
        self.initiator = initiator
        self.paid = paid
        self.taxRate = tax
        self.billAmount = billAmount /* Depricated, no longer in use. Use self.getBillTotal() instead */
        self.entries = entries
    }
    
    
    /// get the date of the bill
    /// - Parameter style: <#style description#>
    /// - Returns: a String representing the date of the bill
    func getDate(style: DateFormatter.Style = DateFormatter.Style.medium) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = style
        return dateFormatter.string(from: self.date)
    }
    
    // MARK: Accessors
    
    // TODO: Get all entries associated with given member (dot index)
    
    /// get the entries involved with a member
    /// - Parameter with: an Int representing the member who we want to get entries for
    /// - Returns: a list of EntryObject that the member is a part of
    func involvedEntries(with: Int) -> [EntryObject] {
        var involved_entries: [EntryObject] = []
        
        for cur_entry in self.entries {
            for cur_participant in cur_entry.getParticipants(){
                if with == cur_participant {
                    involved_entries.append(cur_entry)
                    continue
                }
            }
        }
        // with: an integer representing the target member
        // return: all entries (in a list) that have this target as a participant
        return involved_entries
    }
    
    // TODO: Settle the amount due for one bill, calculation should base on current entries.
    // note: 请自由发挥
    
    /// get the net total of money owed by/to each member for the bill. a positive value means they should be paid back; a negave value means that they owe money for the bill.
    /// - Returns: a list of Doubles that represents how much the member represented by each index owes/should be paid back for the current bill
    func settleBill() -> [Double] {
        var mt = [Double] (repeating: 0.0, count: 10)
        
        for curr_entry in self.entries {
            let per_person = (curr_entry.getEntryTotal())/Double (curr_entry.participants.count)
            for i in curr_entry.participants {
                mt[i] -= per_person
            }
        }
        
        mt[self.initiator] += self.getBillTotal()
        
        return mt
    }
    
    
    /// get the initiator of the bill.
    /// - Returns: an Int representing the inititator of the bill
    func getInitiator() -> Int {
        return self.initiator
    }
    
    
    /// get the attendees of the bill.
    /// - Returns: a list of Ints representing the attendees of the bill
    func getAttendees() -> [Int] {
        return self.attendees
    }
    
    // TODO: Gather all entries and calculate a bill total, in Double Type
    // Don't Forget the tax!
    
    
    /// get the total price value fo the bill.
    /// - Returns: a Double that represents the total value fo the bill
    func getBillTotal() -> Double {
        var total : Double = 0.0;
        //assume tax is included in getEntryTotal() below
        for cur_entry in self.entries {
            total = total + Double(cur_entry.getEntryTotal())
        }
         //if tax is not included in getEntryTotal()  then comment above, uncomment below
         
         /*
         for cur_entry in self.entries {
            total = total + Double(cur_entry.getEntryTotal()*(1 + self.taxRate))
         }
         */
        return total
    }
    
    func getMemberTotal(member: Int) -> Double {
	    var currTotal: Double = 0
	    if member == self.initiator {
		    currTotal += getBillTotal()
	    }

	    for curr_entry in self.entries {
		    currTotal += curr_entry.getMemberTotal(member: member)
	    }

	    return currTotal
    }
    
    // MARK: Muattors
    // TODO: clear all entries
    
    /// clear all entries of the bill.
    mutating func clearEntries(){
        self.entries = []
    }
    
    
    /// mark bill as "paid".
    mutating func markAsPaid() {
        self.paid = true
    }
    
    // TODO: set title
    
    /// change the title of the bill.
    /// - Parameter newTitle: a String representing the new title of the bill
    mutating func setTitle(newTitle: String) {
        self.title = newTitle
    
    }
    
    // TODO: modify bill date
    
    /// change the date of the bill.
    /// - Parameter date: a Date representing the new date of the bill
    mutating func setDate(date: Date) {
        self.date = date
    }
    
    // TODO: set tax rate
    
    /// change the tax rate of the bill.
    /// - Parameter tax: a Double representing the new tax rate of the bill
    mutating func setTaxRate(tax: Double) {
        self.taxRate = tax
    }
    
    // TODO: change initiator
    
    /// change the initiator of the bill.
    /// - Parameter initiator: an Int representing the new initiator of the bill
    mutating func setInitiator(initiator: Int) {
        self.initiator = initiator
        
    }
    
    //TODO: change participants
    
    /// change the attendees/participants of the bill.
    /// - Parameter participants: a list of Ints representing the new attendees/participants of the bill
    mutating func setParticipants(participants: [Int]) {
        self.attendees = participants
        
    }
    
    //TODO: change participants
    
    /// add a participant to the bill
    /// - Parameter participant: an Int representing the participant to be added to the bill
    mutating func addParticipant(participant: Int) {
        self.attendees.append(participant)
        self.attendees.sort()
    }
    
    // TODO: Edit participants: remove at a designated index
    
    /// remove a participant from the bill.
    /// - Parameter at: an Int representing the participant to be removed from the bill
    mutating func removeParticipant(at: Int) {
        self.attendees.remove(at: at)
    }
    
    /// change the paid/unpaid status of a bill
    /// - Parameter isPaid: paid/unpaid status
    mutating func setPaidStatus(isPaid: Bool) {
        self.paid = isPaid
    }
    
    // TODO: add a new entry
    
    /// add a new item entry to the bill using an EntryObject.
    /// - Parameter entry: an EntryObject that represents the new entry to be added
    mutating func addNewEntry(entry: EntryObject) {
        self.entries.append(entry)
        
        // EntryObject(id: <#T##UUID#>, entryTitle: <#T##String#>, participants: <#T##[Int]#>, value: <#T##Double#>, amount: <#T##Int#>, withTax: <#T##Bool#>)
    }
    
    // TODO: add a new entry
    
    /// add a new item entry to the bill using the attributes of an EntryObject.
    /// - Parameters:
    ///   - entryTitle: a String representing the title of the new entry
    ///   - participants: a list of Ints representing the participants of the new entry
    ///   - value: a Double representing the item value of the new entry
    ///   - amount: an Int representing the amount of items of the new entry
    ///   - withTax: a Boolean represnting whether the entry should be taxed or not
    mutating func addNewEntry(entryTitle: String, participants: [Int], value: Double, amount: Int, withTax: Bool) {
        self.entries.append(EntryObject(entryTitle: entryTitle, participants: participants, value: value, amount: amount, withTax: withTax))
    }
    
    // TODO: remove an entry at a designated index
    
    /// remove entry from bill.
    /// - Parameter at: an Int representing the index of the entry to be removed from the list of entries
    mutating func removeEntry(at: Int) {
        self.entries.remove(at: at)
    }
    // MARK: END OF CLASS
}
    
    
extension BillObject {
    static var sample: [BillObject] {
        [
            BillObject(title: "Costco", date: Date() ,attendees: [0, 1, 2, 3, 5, 9], initiator: 2, paid: false, billAmount: 121.0, entries: EntryObject.sample),
            BillObject(title: "Walmart", attendees: [0, 1, 3, 5, 9], initiator: 9, paid: false, billAmount: 67.9, entries: EntryObject.sample),
            BillObject(title: "Bruin Store", date: Date() ,attendees: [2, 4, 5, 9], initiator: 4, paid: false, billAmount: 58.9, entries: EntryObject.sample)
        ]
        
    }
}
