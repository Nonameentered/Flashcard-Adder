import UIKit

var str = ["a", "b", "c", "D"]

let fields = str.reduce("") { fieldString, field -> String in
    "\(fieldString)&fld\(field)=\(field)"
}
//print(fields)
 
let test = "The quick brown {{c1::fox}} jumps {{c1::over::}} {{c3::the::sdf}} lazy dog"

let test2 = """
According to the definition proposed in von Ahn (2005), Foldit—which I de-
scribed in the section on open calls—could be considered a human computation
project. However, I choose to categorize Foldit as an open call, because it requires
specialized skills (although not necessarily formal training) and it takes the best
solution contributed, rather than using a split–apply–combine strategy.
The term “split–apply–combine” was used by Wickham (2011) to describe a
strategy for statistical computing, b
"""

test2.replaceNewlinesWithSpaces
