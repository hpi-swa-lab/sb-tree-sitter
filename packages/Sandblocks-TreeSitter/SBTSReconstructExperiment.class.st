Class {
	#name : #SBTSReconstructExperiment,
	#superclass : #SBTest,
	#classVars : [
		'Lengths',
		'Times'
	],
	#category : #'Sandblocks-TreeSitter-Tests'
}

{ #category : #'as yet unclassified' }
SBTSReconstructExperiment class >> clearTimes [

	Times := nil.
	Lengths := nil
]

{ #category : #'as yet unclassified' }
SBTSReconstructExperiment class >> reportLength: aNumber [

	Lengths ifNil: [Lengths := OrderedCollection new].
	Lengths add: aNumber
]

{ #category : #'as yet unclassified' }
SBTSReconstructExperiment class >> reportTime: aTimeSpan [

	Times ifNil: [Times := OrderedCollection new].
	Times add: aTimeSpan
]

{ #category : #'as yet unclassified' }
SBTSReconstructExperiment class >> runAllAndCopyToClipboard [

	self clearTimes.
	self basicNew commitExpressJS.
	self basicNew commitOvertoneClojure.
	self basicNew commitFlaskPython.
	self writeTimes
]

{ #category : #'as yet unclassified' }
SBTSReconstructExperiment class >> times [

	^ Times
]

{ #category : #'as yet unclassified' }
SBTSReconstructExperiment class >> writeTimes [

	Clipboard clipboardText: ((self times collect: [:t | t asMicroSeconds]) joinSeparatedBy: String cr).
	UIManager default confirm: 'next?'.
	Clipboard clipboardText: (Lengths joinSeparatedBy: String cr)
]

{ #category : #'as yet unclassified' }
SBTSReconstructExperiment >> commitExpressJS [

	self runTests: '/home/tom/Code/squeak/sle2022-partial-parser/express.json' language: SBJavascript
]

{ #category : #'as yet unclassified' }
SBTSReconstructExperiment >> commitFlaskPython [

	self runTests: '/home/tom/Code/squeak/sle2022-partial-parser/flask.json' language: SBPython
]

{ #category : #'as yet unclassified' }
SBTSReconstructExperiment >> commitOvertoneClojure [

	self runTests: '/home/tom/Code/squeak/sle2022-partial-parser/overtone.json' language: SBClojure
]

{ #category : #'as yet unclassified' }
SBTSReconstructExperiment >> randomBlockIn: aBlock [

	^ (Array streamContents: [:array | aBlock allBlocksDo: [:b | (b sourceStringForCompare size between: 1 and: 20) ifTrue: [array nextPut: b]]]) atRandom
]

{ #category : #'as yet unclassified' }
SBTSReconstructExperiment >> rangeFrom: aChange [

	| startInset endInset |
	startInset := aChange typed size - aChange typed withoutLeadingBlanks size.
	endInset := aChange typed size - aChange typed withoutTrailingBlanks size.
	aChange typed last = $; ifTrue: [endInset := endInset + 1].
	^ (SBTSPosition line: aChange line - 1 character: aChange startColumn + startInset) -> (SBTSPosition line: aChange line - 1 character: aChange endColumn - endInset)
]

{ #category : #'as yet unclassified' }
SBTSReconstructExperiment >> runRandomTestsFor: aLanguage source: aString [

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
SBTSReconstructExperiment >> runTests: aPathString language: aLanguage [

	| changes actualCount |
	changes := FileStream readOnlyFileNamed: aPathString do: [:stream | Json readFrom: stream].
	actualCount := 0.
	((changes first: 100) select: [:change | change typed notEmpty])
		do: [:change |
			[ | program block string editor originalSource |
				program := aLanguage parseToplevel: change fullSourceCode.
				originalSource := program sourceStringForCompare.
				block := program smallestBlockEncompassig: (self rangeFrom: change).
				"skip comments and python string-comments as they are of little interest"
				(block type = #comment or: [block type = #string and: [{'"""'. ''''''''} includes: block textMorphs first contents]]) ifFalse: [
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
					SBToggledCode comment: '' active: 1 do: {
						[
							originalSource = program sourceStringForCompare
								ifFalse: [
									string = '.' ifTrue: [self halt].
									Transcript showln: 'failed: ', string]
								ifTrue: [actualCount := actualCount + 1]].
						[self assert: originalSource equals: program sourceStringForCompare]}.
					actualCount = 30 ifTrue: [^ self]]]
				on: SBTSSyntaxError
				do: []]
		displayingProgress: [:change | change typed].
	"if we reach here we did not find 30 valid items in the first 100"
	self assert: false
]

{ #category : #'as yet unclassified' }
SBTSReconstructExperiment >> sampleProject: aPath language: aLanguage [

	| candidates random |
	candidates := (FileDirectory on: aPath) fullNamesOfAllFilesInSubtree select: [:path | path endsWith: aLanguage fileSuffix].
	
	random := Random seed: 123.
	50 timesRepeat: [ | file target editor source original path |
		path := candidates atRandom: random.
		file := [(SBTSFile forNoReplace: path) root] on: Error do: [nil].
		file
			ifNotNil: [
				target := (Array streamContents: [:stream | file allBlocksDo: [:b | (b isSingleLine and: [b type ~= #empty]) ifTrue: [stream nextPut: b]]]) atRandom: random.
				
				original := file sourceStringForCompare.
				source := target sourceString.
				editor := self editorAndWorldFor: file.
				Transcript showln: {path. source}.
				target changeToUnknown.
				self type: source in: editor.
				editor
					allBlocksDetect: [:b | b isKindOf: SBTSInputReconcile]
					ifFound: [:x |
						self tick.
						self tick.
						editor handle: (self keyboardEvent: Character cr)]
					ifNone: [].
				self assert: original equals: file sourceStringForCompare]
			ifNil: [Transcript showln: 'failed to parse: ', path]]
]
