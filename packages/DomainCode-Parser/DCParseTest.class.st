Class {
	#name : #DCParseTest,
	#superclass : #SBTest,
	#category : #'DomainCode-Parser-Test'
}

{ #category : #'as yet unclassified' }
DCParseTest >> testChangeDeleteInFirstLine [

	| edit |
	edit := DCBlock findChangeRangeFrom: 'abc' to: 'ac'.
	self assert: 1 equals: edit startByte.
	self assert: 2 equals: edit oldEndByte.
	self assert: 1 equals: edit newEndByte.
	self assert: (SBTSPoint row: 0 column: 1) equals: edit startPoint.
	self assert: (SBTSPoint row: 0 column: 2) equals: edit oldEndPoint.
	self assert: (SBTSPoint row: 0 column: 1) equals: edit newEndPoint
]

{ #category : #'as yet unclassified' }
DCParseTest >> testChangeDeleteInLaterLine [

	| edit |
	edit := DCBlock findChangeRangeFrom: 'abc


def
ghi' to: 'abc


df
ghi'.
	self assert: 7 equals: edit startByte.
	self assert: 8 equals: edit oldEndByte.
	self assert: 7 equals: edit newEndByte.
	self assert: (SBTSPoint row: 3 column: 1) equals: edit startPoint.
	self assert: (SBTSPoint row: 3 column: 2) equals: edit oldEndPoint.
	self assert: (SBTSPoint row: 3 column: 1) equals: edit newEndPoint
]

{ #category : #'as yet unclassified' }
DCParseTest >> testChangeDeleteLineBreak [

	| edit |
	edit := DCBlock findChangeRangeFrom: 'abc


def
ghi' to: 'abc

def
ghi'.
	self assert: 5 equals: edit startByte.
	self assert: 6 equals: edit oldEndByte.
	self assert: 5 equals: edit newEndByte.
	self assert: (SBTSPoint row: 2 column: 0) equals: edit startPoint.
	self assert: (SBTSPoint row: 3 column: 0) equals: edit oldEndPoint.
	self assert: (SBTSPoint row: 2 column: 0) equals: edit newEndPoint
]

{ #category : #'as yet unclassified' }
DCParseTest >> testChangeDeleteWithRepeating [

	| edit |
	edit := DCBlock findChangeRangeFrom: 'aab' to: 'ab'.
	self assert: 1 equals: edit startByte.
	self assert: 2 equals: edit oldEndByte.
	self assert: 1 equals: edit newEndByte.
	self assert: (SBTSPoint row: 0 column: 1) equals: edit startPoint.
	self assert: (SBTSPoint row: 0 column: 2) equals: edit oldEndPoint.
	self assert: (SBTSPoint row: 0 column: 1) equals: edit newEndPoint
]

{ #category : #'as yet unclassified' }
DCParseTest >> testChangeInsert [

	| edit |
	edit := DCBlock findChangeRangeFrom: 'ac' to: 'abc'.
	self assert: 1 equals: edit startByte.
	self assert: 1 equals: edit oldEndByte.
	self assert: 2 equals: edit newEndByte.
	self assert: (SBTSPoint row: 0 column: 1) equals: edit startPoint.
	self assert: (SBTSPoint row: 0 column: 1) equals: edit oldEndPoint.
	self assert: (SBTSPoint row: 0 column: 2) equals: edit newEndPoint
]

{ #category : #'as yet unclassified' }
DCParseTest >> testChangeInsertAtEnd [

	| edit |
	edit := DCBlock findChangeRangeFrom: 'ab' to: 'abcd'.
	self assert: 2 equals: edit startByte.
	self assert: 2 equals: edit oldEndByte.
	self assert: 4 equals: edit newEndByte.
	self assert: (SBTSPoint row: 0 column: 2) equals: edit startPoint.
	self assert: (SBTSPoint row: 0 column: 2) equals: edit oldEndPoint.
	self assert: (SBTSPoint row: 0 column: 4) equals: edit newEndPoint
]

{ #category : #'as yet unclassified' }
DCParseTest >> testChangeInsertOnLaterLine [

	| edit |
	edit := DCBlock findChangeRangeFrom: 'a

ac' to: 'a

abc'.
	self assert: 4 equals: edit startByte.
	self assert: 4 equals: edit oldEndByte.
	self assert: 5 equals: edit newEndByte.
	self assert: (SBTSPoint row: 2 column: 1) equals: edit startPoint.
	self assert: (SBTSPoint row: 2 column: 1) equals: edit oldEndPoint.
	self assert: (SBTSPoint row: 2 column: 2) equals: edit newEndPoint
]

{ #category : #'as yet unclassified' }
DCParseTest >> testChangeInsertStringWithLinebreak [

	| edit |
	edit := DCBlock findChangeRangeFrom: 'a

ai' to: 'a

abc
def
ghi'.
	self assert: 4 equals: edit startByte.
	self assert: 4 equals: edit oldEndByte.
	self assert: 13 equals: edit newEndByte.
	self assert: (SBTSPoint row: 2 column: 1) equals: edit startPoint.
	self assert: (SBTSPoint row: 2 column: 1) equals: edit oldEndPoint.
	self assert: (SBTSPoint row: 4 column: 2) equals: edit newEndPoint
]

{ #category : #'as yet unclassified' }
DCParseTest >> testChangeInsertWithRepeating [

	| edit |
	edit := DCBlock findChangeRangeFrom: 'aaab' to: 'aaaab'.
	self assert: 3 equals: edit startByte.
	self assert: 3 equals: edit oldEndByte.
	self assert: 4 equals: edit newEndByte.
	self assert: (SBTSPoint row: 0 column: 3) equals: edit startPoint.
	self assert: (SBTSPoint row: 0 column: 3) equals: edit oldEndPoint.
	self assert: (SBTSPoint row: 0 column: 4) equals: edit newEndPoint
]

{ #category : #'as yet unclassified' }
DCParseTest >> testEditDeleteFirstLine [

	DCBlock deleteFrom: 'abc' at: 2 do: [:new :edit :undo |
		self assert: 'ac' equals: new.
		self assert: 1 equals: edit startByte.
		self assert: 2 equals: edit oldEndByte.
		self assert: 1 equals: edit newEndByte.
		self assert: (SBTSPoint row: 0 column: 1) equals: edit startPoint.
		self assert: (SBTSPoint row: 0 column: 2) equals: edit oldEndPoint.
		self assert: (SBTSPoint row: 0 column: 1) equals: edit newEndPoint.
		
		undo value: 'ac' value: [:undoNew :undoEdit :undoUndo | self assert: 'abc' equals: undoNew]]
]

{ #category : #'as yet unclassified' }
DCParseTest >> testEditDeleteLaterLine [

	DCBlock deleteFrom: 'abc


def
ghi' at: 8 do: [:new :edit :undo |
		self assert: 'abc


df
ghi' equals: new.
		self assert: 7 equals: edit startByte.
		self assert: 8 equals: edit oldEndByte.
		self assert: 7 equals: edit newEndByte.
		self assert: (SBTSPoint row: 3 column: 1) equals: edit startPoint.
		self assert: (SBTSPoint row: 3 column: 2) equals: edit oldEndPoint.
		self assert: (SBTSPoint row: 3 column: 1) equals: edit newEndPoint]
]

{ #category : #'as yet unclassified' }
DCParseTest >> testEditDeleteLineBreak [

	DCBlock deleteFrom: 'abc


def
ghi' at: 4 do: [:new :edit :undo |
		self assert: 'abc

def
ghi' equals: new.
		self assert: 3 equals: edit startByte.
		self assert: 4 equals: edit oldEndByte.
		self assert: 3 equals: edit newEndByte.
		self assert: (SBTSPoint row: 0 column: 3) equals: edit startPoint.
		self assert: (SBTSPoint row: 1 column: 0) equals: edit oldEndPoint.
		self assert: (SBTSPoint row: 0 column: 3) equals: edit newEndPoint]
]

{ #category : #'as yet unclassified' }
DCParseTest >> testEditInsert [

	DCBlock insert: 'b' in: 'ac' at: 2 do: [:new :edit :undo |
		self assert: 'abc' equals: new.
		self assert: 1 equals: edit startByte.
		self assert: 1 equals: edit oldEndByte.
		self assert: 2 equals: edit newEndByte.
		self assert: (SBTSPoint row: 0 column: 1) equals: edit startPoint.
		self assert: (SBTSPoint row: 0 column: 1) equals: edit oldEndPoint.
		self assert: (SBTSPoint row: 0 column: 2) equals: edit newEndPoint.
		
		undo value: 'abc' value: [:undoNew :undoEdit :undoUndo | self assert: 'ac' equals: undoNew]]
]

{ #category : #'as yet unclassified' }
DCParseTest >> testEditInsertAtEnd [

	DCBlock insert: 'cd' in: 'ab' at: 3 do: [:new :edit :undo |
		self assert: 'abcd' equals: new.
		self assert: 2 equals: edit startByte.
		self assert: 2 equals: edit oldEndByte.
		self assert: 4 equals: edit newEndByte.
		self assert: (SBTSPoint row: 0 column: 2) equals: edit startPoint.
		self assert: (SBTSPoint row: 0 column: 2) equals: edit oldEndPoint.
		self assert: (SBTSPoint row: 0 column: 4) equals: edit newEndPoint]
]

{ #category : #'as yet unclassified' }
DCParseTest >> testEditInsertOnLaterLine [

	DCBlock insert: 'b' in: 'a

ac' at: 5 do: [:new :edit :undo |
		self assert: 'a

abc' equals: new.
		self assert: 4 equals: edit startByte.
		self assert: 4 equals: edit oldEndByte.
		self assert: 5 equals: edit newEndByte.
		self assert: (SBTSPoint row: 2 column: 1) equals: edit startPoint.
		self assert: (SBTSPoint row: 2 column: 1) equals: edit oldEndPoint.
		self assert: (SBTSPoint row: 2 column: 2) equals: edit newEndPoint]
]

{ #category : #'as yet unclassified' }
DCParseTest >> testEditInsertStringWithLinebreak [

	DCBlock insert: 'bc
def
gh' in: 'a

ai' at: 5 do: [:new :edit :undo |
		self assert: 'a

abc
def
ghi' equals: new.
		self assert: 4 equals: edit startByte.
		self assert: 4 equals: edit oldEndByte.
		self assert: 13 equals: edit newEndByte.
		self assert: (SBTSPoint row: 2 column: 1) equals: edit startPoint.
		self assert: (SBTSPoint row: 2 column: 1) equals: edit oldEndPoint.
		self assert: (SBTSPoint row: 4 column: 2) equals: edit newEndPoint]
]

{ #category : #'as yet unclassified' }
DCParseTest >> testEditReplace [

	DCBlock replace: (SBTSRange start: 2 size: 4) in: 'abxxxxef' with: 'cd' do: [:new :edit :undo |
		self assert: 'abcdef' equals: new.
		
		undo
			value: 'abcdef'
			value: [:undoNew :undoEdit :undoUndo | self assert: 'abxxxxef' equals: undoNew]]
]

{ #category : #'as yet unclassified' }
DCParseTest >> testEditSwapString [

	DCBlock
		swap: (SBTSRange start: 4 size: 3)
		with: (SBTSRange start: 8 size: 6)
		in: 'abc
def
ghijkl
mno'
		do: [:new :edit :undo |
			self assert: 'abc
ghijkl
def
mno' equals: new.
			self assert: 4 equals: edit startByte.
			self assert: 14 equals: edit oldEndByte.
			self assert: 14 equals: edit newEndByte.
			self assert: (SBTSPoint row: 1 column: 0) equals: edit startPoint.
			self assert: (SBTSPoint row: 2 column: 6) equals: edit oldEndPoint.
			self assert: (SBTSPoint row: 2 column: 3) equals: edit newEndPoint.
			
			undo
				value: 'abc
ghijkl
def
mno'
				value: [:undoNew :undoEdit :undoUndo | self assert: 'abc
def
ghijkl
mno' equals: undoNew]]
]

{ #category : #'as yet unclassified' }
DCParseTest >> testKeepEmptyLine [

	| program editor |
	program := DCBlock parse: 'a;

b;' language: SBJavascript.
	editor := self editorAndWorldFor: program.
	program lastDeepChild startInputAtEnd.
	self type: 'b' in: editor.
	self assert: 4 equals: editor childSandblocks first submorphs size
]

{ #category : #'as yet unclassified' }
DCParseTest >> testParseIdentifierWithPrecedingLineBreak [

	| program |
	program := DCBlock parse: '

b' language: SBJavascript.
	self assert: 3 equals: program submorphCount
]
