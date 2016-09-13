//
//  sudokusolver.swift
//  
//
//  Created by Ryan Knauer on 9/10/16.
//
//

import Foundation




// =======================
// create matrix :

func makePossibleArray(size: Int) -> [Int] {
    var possible = [Int]()
    for i in 1...size{
        possible.append(i)
    }
    return possible
}


struct Matrix {
    let size: Int
    var grid: [[Int]]
    init(size: Int) {
        self.size = size
        let possible = makePossibleArray(size)
        grid = Array(count: size * size, repeatedValue: possible)
    }
    func indexIsValidForRow(row: Int, column: Int) -> Bool {
        return row >= 0 && row < size && column >= 0 && column < size
    }
    subscript(row: Int, column: Int) -> [Int] {
        get {
            assert(indexIsValidForRow(row, column: column), "Index out of range")
            return grid[(row * size) + column]
        }
        set {
            assert(indexIsValidForRow(row, column: column), "Index out of range")
            grid[(row * size) + column] = newValue
        }
        
    }
}


// Example matrix for tests:
var sudoku = Matrix(size: 9)

var sudoku2 = Matrix(size: 3)

// ===================
// Constants:
let gridSize = sudoku.grid.count
let rowSize: Int = Int(sqrt(Double(gridSize)))
let maxRow = rowSize - 1
let boxNumber = Int(sqrt(Double(rowSize)))   // both size of box's and number of boxes
// create simplifying algorithims




// Matrix -> Matrix
// Get rid of impossibles in possibility lists.
// Using row(horizontal method

func solveSudoku(sudoku: Matrix) {
    var lastGrid: [[Int]] = [[100]] //just starting value placeholder
    for r in 0...maxRow {
        for c in 0...maxRow{
            if sudoku[r, c].count == 1 {
                continue
            } else if lastGrid == sudoku.grid{
                bruteforce(sudoku)
            } else {
                lastGrid = sudoku.grid
                rowSimplify(r, col: c)
                colSimplify(r, col: c)
                boxSimplify(r, col: c)
                checkBoxes()
                checkRows()
                checkCollumns()
            }
        }
        
    }
}


func bruteforce(sud: Matrix) -> Bool{
    if (solved(sud)){
        sudoku = sud
        return true
    }
    else{
        for i in 0...sud.grid.count - 1{
            let box = sud.grid[i]
            if box.count > 1{
                for j in box{
                    var testSudoku: Matrix =  sud
                    let singleArray: [Int] = [j]
                    testSudoku.grid[i] = singleArray
                    if bruteforce(testSudoku) == true{
                        return true
                    }
                }
            
            }
        }
        return false
    }
    
}



func solved(sud: Matrix) -> Bool{
    for r in 0...maxRow {
        for c in 0...maxRow{
            if sudoku[r, c].count == 1{
                continue
            }else{
                return false
            }
        }
    }
    return true
}


func rowSimplify(row: Int, col: Int) {
    for i in 0...maxRow {
        checkReplace(row, origCol: col, checkRow: row, checkCol: i)
    }
}

func colSimplify(row: Int, col: Int) {
    for i in 0...maxRow {
        checkReplace(row, origCol: col, checkRow: i, checkCol: col)
    }
}


func boxSimplify(row: Int, col: Int) {
    var startingBox = findBoxQuardinates(row, col:  col)
    let startRow = startingBox[0]
    let startCol = startingBox[1]
    for r in 0...boxNumber - 1{
        for c in 0...boxNumber - 1{
            checkReplace(row, origCol: col, checkRow: startRow + r, checkCol: startCol + c)
        }
    }
}

func findBoxQuardinates(row: Int, col: Int) ->[Int] {
    var qrow = Int()
    var qcol = Int()
    var arr: [Int]
    for i in 0...maxRow {
        if (row - i) <= 1{
            qrow = 0
            break
        }else if (row - i) % boxNumber == 0{
            qrow = (row - i)
            break
        } else {
            continue
        }
    }
    for i in 0...maxRow {
        if (col - i) <= 1{
            qcol = 0
            break
        } else if (col - i) % boxNumber == 0{
            qcol = (col - i)
            break
        } else {
            continue
        }
    }
    arr = [qrow, qcol]
    return arr
}




func checkReplace(origRow: Int, origCol: Int, checkRow: Int, checkCol: Int){
    if sudoku[checkRow, checkCol].count == 1 &&
        sudoku[origRow, origCol].indexOf(sudoku[checkRow, checkCol][0]) != nil &&
        sudoku[origRow, origCol].count > 1{
            sudoku[origRow, origCol].removeAtIndex(sudoku[origRow, origCol].indexOf(sudoku[checkRow, checkCol][0])!)
    }
}




func appendRows(sudoku: Matrix) ->[[Int]]{
    var rowAllPoss = [[Int]](count: rowSize, repeatedValue: [Int]())
    for r in 0...maxRow{
        for i in 0...maxRow{
            rowAllPoss[r] += sudoku[r, i]
        }
    }
    return rowAllPoss
}



func appendCol(sudoku: Matrix) ->[[Int]]{
    var colAllPoss = [[Int]](count: rowSize, repeatedValue: [Int]())
    for c in 0...maxRow{
        for i in 0...maxRow{
            colAllPoss[c] += sudoku[i, c]
        }
    }
    return colAllPoss
}



func appendBoxes(Sudoku: Matrix) ->[[Int]]{
    var boxAllPoss = [[Int]](count: rowSize, repeatedValue: [Int]())
    let boxSize = boxNumber - 1
    var rowMultiplier: Int = 0
    var colMultiplier: Int = 0
    for boxIter in 0...maxRow{
        if boxIter % boxNumber == 0 && boxIter > 0 {
            rowMultiplier = rowMultiplier + 1
            colMultiplier = 0
        } else if boxIter > 0 {
            colMultiplier = colMultiplier + 1
        }
        for r in 0 + (rowMultiplier * boxNumber)...boxSize + (rowMultiplier * boxNumber){
            for c in 0 + (colMultiplier * boxNumber)...boxSize + (colMultiplier * boxNumber){
                boxAllPoss[boxIter] += sudoku[r, c]
            }
        }
    }
    return boxAllPoss
}





func findCInBox(c: Int, row: Int){
    var counter = 0
    var rowCountDown = row
    while rowCountDown >= boxNumber{
        rowCountDown = rowCountDown - boxNumber
        counter = counter + 1
    }
    let startingBlockRow = (counter * boxNumber)
    let startingBlockCol = (rowCountDown * boxNumber)
    for r in 0...(boxNumber - 1){
        for col in 0...(boxNumber - 1){
            if sudoku[(startingBlockRow + r), (startingBlockCol + col)].contains(c){
                sudoku[(startingBlockRow + r), (startingBlockCol + col)] = [c]
            }
        }
    }
}




func findCInRow(c: Int, row: Int) {
    for col in 0...maxRow{
        if sudoku[row, col].contains(c){
            sudoku[row, col] = [c]
        }
    }
}



func findCInCollumn(c: Int, collumn: Int) {
    for row in 0...maxRow{
        if sudoku[row, collumn].contains(c){
            sudoku[row, collumn] = [c]
        }
    }
}




func checkRows(){
    var rowPoss = appendRows(sudoku)
    var counter = 0
    for row in 0...maxRow{
        for c in 0...maxRow{
            for col in 0...rowPoss[row].count - 1{
                if rowPoss[row][col] == c{
                    counter = counter + 1
                }
            }
            if counter == 1{
                findCInRow(c, row: row)
            }
            counter = 0
        }
    }
}



func checkCollumns(){
    var colPos = appendCol(sudoku)
    var counter = 0
    for col in 0...maxRow{
        for c in 0...maxRow{
            for row in 0...colPos[col].count - 1{
                if colPos[col][row] == c{
                    counter = counter + 1
                }
            }
            if counter == 1{
                findCInCollumn(c, collumn: col)
            }
            counter = 0
        }
    }
}


func checkBoxes(){
    var boxPos = appendBoxes(sudoku)
    var counter = 0
    for rowCounter in 0...maxRow{
        for c in 0...maxRow{
            for colCounter in 0...boxPos[rowCounter].count - 1{
                if boxPos[rowCounter][colCounter] == c{
                    counter = counter + 1
                }
            }
            if counter == 1{
                findCInBox(c, row: rowCounter)
            }
            counter = 0
        }
    }
    
}





func printSudoku(sudoku: Matrix){
    for i in 0...maxRow{
        print(sudoku.grid[(rowSize * i)...((rowSize * (i + 1)) - 1)])
    }
}


//==========================
// Tests:







sudoku[0, 2] = [8]
sudoku[0, 6] = [6]
sudoku[1, 1] = [4]
sudoku[1, 7] = [3]
sudoku[1, 8] = [7]
sudoku[2, 1] = [7]
sudoku[2, 7] = [2]
sudoku[2, 8] = [5]
sudoku[3, 5] = [2]
sudoku[4, 0] = [3]
sudoku[4, 2] = [9]
sudoku[4, 5] = [1]
sudoku[4, 6] = [7]
sudoku[5, 3] = [6]
sudoku[5, 4] = [9]
sudoku[5, 8] = [8]
sudoku[6, 0] = [5]
sudoku[6, 5] = [3]
sudoku[7, 4] = [4]
sudoku[7, 5] = [7]
sudoku[8, 1] = [8]
sudoku[8, 6] = [4]

//solveSudoku(sudoku)
//printSudoku(sudoku)
//print("===============\n")
//solveSudoku(sudoku)
//printSudoku(sudoku)
//print("===============\n")
//solveSudoku(sudoku)

solveSudoku(sudoku)
printSudoku(sudoku)
print("===============\n")
bruteforce(sudoku)
printSudoku(sudoku)
print(solved(sudoku))
print(bruteforce(sudoku))

