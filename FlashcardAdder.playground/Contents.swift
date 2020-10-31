import UIKit

var str = ["a", "b", "c", "D"]

let fields = str.reduce("") { fieldString, field -> String in
    "\(fieldString)&fld\(field)=\(field)"
}
//print(fields)
 
let test = "The quick brown {{c1::fox}} jumps {{c1::over::}} {{c3::the::sdf}} lazy dog"
