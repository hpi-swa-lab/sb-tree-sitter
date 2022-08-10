Class {
	#name : #SBTSReconstructTest,
	#superclass : #SBTest,
	#category : #'Sandblocks-TreeSitter-Tests'
}

{ #category : #'as yet unclassified' }
SBTSReconstructTest >> randomBlockIn: aBlock [

	^ (Array streamContents: [:array | aBlock allBlocksDo: [:b | (b sourceStringForCompare size between: 1 and: 20) ifTrue: [array nextPut: b]]]) atRandom
]

{ #category : #'as yet unclassified' }
SBTSReconstructTest >> rangeFrom: aChange [

	| startInset endInset |
	startInset := aChange typed size - aChange typed withoutLeadingBlanks size.
	endInset := aChange typed size - aChange typed withoutTrailingBlanks size.
	aChange typed last = $; ifTrue: [endInset := endInset + 1].
	^ (SBTSPosition line: aChange line - 1 character: aChange startColumn + startInset) -> (SBTSPosition line: aChange line - 1 character: aChange endColumn - endInset)
]

{ #category : #'as yet unclassified' }
SBTSReconstructTest >> runTestsFor: aLanguage source: aString [

	| program source editor types |
	program := aLanguage parseToplevel: aString.
	editor := self editorAndWorldFor: program.
	source := program sourceStringForCompare.
	types := Array streamContents: [:stream | program allBlocksDo: [:block | stream nextPut: block type]].
	
	10 timesRepeat: [ | target targetSourceString |
		target := self randomBlockIn: program.
		targetSourceString := target sourceString.
		target changeToUnknown.
		self type: targetSourceString in: editor.
		editor
			allBlocksDetect: [:b | b isKindOf: SBTSInputReconcile]
			ifFound: [:x |
				self tick.
				self tick.
				editor handle: (self keyboardEvent: Character cr)]
			ifNone: [].
		self assert: source equals: program sourceStringForCompare.
		self assert: (types hasEqualElements: (Array streamContents: [:stream | program allBlocksDo: [:block | stream nextPut: block type]]))]
]

{ #category : #'as yet unclassified' }
SBTSReconstructTest >> testJsonCommitExpressJS [
	<timeout: 100000>

	| changes |
	changes := FileStream
		readOnlyFileNamed: '/home/tom/Code/squeak/sle2022-partial-parser/express.json'
		do: [:stream | Json readFrom: stream].
	(changes first: 30)
		do: [:change |
			[ | program block string editor originalSource |
				program := SBJavascript parseToplevel: change fullSourceCode.
				originalSource := program sourceStringForCompare.
				block := program smallestBlockEncompassig: (self rangeFrom: change).
				string := block sourceString.
				self assert: string size < 300.
				string last = $; ifTrue: [string := string allButLast].
				editor := self editorAndWorldFor: program.
				block changeToUnknown.
				self type: string in: editor.
				editor
					allBlocksDetect: [:b | b isKindOf: SBTSInputReconcile]
					ifFound: [:x |
						self tick.
						self tick.
						editor handle: (self keyboardEvent: Character cr)]
					ifNone: [].
				self assert: originalSource equals: program sourceStringForCompare]
				on: SBTSSyntaxError
				do: []]
		displayingProgress: 'file'
]
