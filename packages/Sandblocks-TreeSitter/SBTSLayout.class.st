"
A SBAlgebraLayout is a layout policy that calls uses Commands to arrive at a layout. For example, a command could be #softLine, instructing the layout to only place a linebreak here if there is not enough horizontal space otherwise.

Each Morph can implement #layoutCommands, which must return a SBAlgebraCommand. If you want to use the SBAlgebraLayout, assign this layoutPolicy to all morphs in your subtree. The layoutPolicy will then take care that only the topmost layout will actually perform any positioning (#isAlgebraLayoutRoot:).

The algorithm is based on this paper: http://homepages.inf.ed.ac.uk/wadler/papers/prettier/prettier.pdf
See also this article for a simple explanation: https://blog.vjeux.com/2017/javascript/anatomy-of-a-javascript-pretty-printer.html
"
Class {
	#name : #SBTSLayout,
	#superclass : #LayoutPolicy,
	#instVars : [
		'measure',
		'minExtentCache',
		'cache',
		'placementStream',
		'bottomRightLayoutState'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSLayout class >> gap [

	^ 6 sbScaled
]

{ #category : #'as yet unclassified' }
SBTSLayout class >> indent [

	^ 10 sbScaled
]

{ #category : #'as yet unclassified' }
SBTSLayout class >> verticalGap [

	^ 2 sbScaled
]

{ #category : #'as yet unclassified' }
SBTSLayout >> bottomRightLayoutState [

	^ bottomRightLayoutState
]

{ #category : #'as yet unclassified' }
SBTSLayout >> bottomRightLayoutState: aPoint [

	bottomRightLayoutState := aPoint
]

{ #category : #'as yet unclassified' }
SBTSLayout >> flushLayoutCache [

	minExtentCache := nil
]

{ #category : #'as yet unclassified' }
SBTSLayout >> initialize [

	bottomRightLayoutState := 0 @ 0
]

{ #category : #'as yet unclassified' }
SBTSLayout >> isLayoutRoot: aMorph [

	^ aMorph owner isNil or: [aMorph owner layoutPolicy class ~= self class]
]

{ #category : #'as yet unclassified' }
SBTSLayout >> layout: aMorph in: aRectangle [

	| x y nextIsNewLine indent |
	(self isLayoutRoot: aMorph) ifFalse: [^ self].
	
	true ifTrue: [
		^ aMorph layout: (SBTSLayoutState new
			minX: aRectangle left;
			maxX: aRectangle right;
			gap: self class gap)].
	
	x := aRectangle left.
	y := aRectangle top.
	indent := 0.
	nextIsNewLine := false.
	
	aMorph allMorphsDo: [:m |
		(m isTextMorph or: [m isStringMorph])
			ifTrue: [ | extent newX |
				extent := m minExtent.
				newX := x + extent x + self class gap.
				m contents = '}' ifTrue: [indent := indent - 1].
				(newX > aRectangle right or: [nextIsNewLine or: [m contents = '}']]) ifTrue: [
					x := aRectangle left + (indent * self class indent).
					newX := x + (extent x + self class gap).
					y := y + extent y.
					nextIsNewLine := false].
				m contents = '{' ifTrue: [
					nextIsNewLine := true.
					indent := indent + 1].
				m setFinalBounds: (x @ y extent: extent).
				x := newX]
			ifFalse: [
				m = aMorph ifFalse: [
					m setFinalBounds: m submorphBounds.
					m owner isBlockBody ifTrue: [nextIsNewLine := true]]]].
	
	" if we do not have an owner, enforce our minSize ourselves"
	SBToggledCode comment: '' active: 0 do: {
		[(aMorph owner isNil or: [aMorph owner layoutPolicy isNil]) ifTrue: [aMorph extent: 0 @ 0 + aMorph layoutInset asEdgeInsets]]}
]

{ #category : #'as yet unclassified' }
SBTSLayout >> minExtentOf: aMorph in: aRectangle [

	minExtentCache ifNotNil: [^ minExtentCache].
	
	^ minExtentCache := 0 @ 0
]
