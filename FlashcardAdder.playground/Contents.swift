import UIKit

var str = ["a", "b", "c", "D"]

let fields = str.reduce("") { fieldString, field -> String in
    "\(fieldString)&fld\(field)=\(field)"
}
print(fields)
 
