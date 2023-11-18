Class {
	#name : #DCLayoutInfo,
	#superclass : #Object,
	#instVars : [
		'morphs',
		'x',
		'y',
		'lineHeight',
		'bounds',
		'lineStart',
		'depth',
		'padding',
		'baseline',
		'lineStartY'
	],
	#category : #'DomainCode-Parser'
}

{ #category : #'as yet unclassified' }
DCLayoutInfo >> advance: aPoint [

	x := x + aPoint x.
	lineHeight := lineHeight max: aPoint y
]

{ #category : #'as yet unclassified' }
DCLayoutInfo >> bounds [

	^ bounds
]

{ #category : #'as yet unclassified' }
DCLayoutInfo >> depth [

	^ depth
]

{ #category : #'as yet unclassified' }
DCLayoutInfo >> depth: aNumber [

	depth := aNumber
]

{ #category : #'as yet unclassified' }
DCLayoutInfo >> extent [

	^ self position + (0 @ lineHeight)
]

{ #category : #'as yet unclassified' }
DCLayoutInfo >> initialize [

	lineHeight := 0.
	depth := 0
]

{ #category : #'as yet unclassified' }
DCLayoutInfo >> layoutRoot: aMorph at: aPoint [

	| line flushLine |
	self
		origin: aPoint;
		lineStart: aPoint x;
		padding: aMorph layoutInset.
	
	morphs := Array streamContents: [:s | aMorph allLayoutMorphsDo: [:b | s nextPut: b]].
	
	line := OrderedCollection new.
	baseline := 0.
	lineStartY := aPoint y - aMorph layoutInset asEdgeInsets top.
	
	flushLine := [
		line do: [:tuple | | bounds |
			bounds := tuple size = 3
				ifTrue: [tuple second @ (lineStartY + baseline) extent: tuple third]
				ifFalse: [tuple first nonExtraChildrenBounds expandBy: tuple first layoutInset asEdgeInsets].
			tuple first setBoundsDirect: bounds.
			y := y max: bounds bottom.
			tuple size = 3 ifTrue: [tuple first doLayoutIn: (bounds insetBy: tuple first layoutInset)]].
		line removeAll.
		
		x := lineStart.
		lineStartY := y.
		baseline := 0].
	
	morphs viewAllButFirstAndLast do: [:m |
		true
			caseOf: {
				[m class = Array] -> [ | inset |
					"leave"
					line add: {m second. x}.
					inset := m second layoutInset asEdgeInsets.
					x := x + inset right.
					y := y - inset top.
					lineStart := lineStart - inset left].
				[m isLineBreak] -> [
					line add: {m. x. m minExtent}.
					flushLine value].
				[m class = DCBlock] -> [ | inset |
					inset := m layoutInset asEdgeInsets.
					x := x + inset left.
					y := y + inset top.
					lineStart := lineStart + inset left.
					baseline := baseline max: y - lineStartY]}
			otherwise: [ | extent |
				extent := m minExtent.
				line add: {m. x. extent}.
				x := x + extent x]].
	
	flushLine value.
	
	aMorph setBoundsDirect: (aPoint - aMorph layoutInset asEdgeInsets topLeft extent: (aMorph submorphBounds expandBy: aMorph layoutInset asEdgeInsets) extent)
]

{ #category : #'as yet unclassified' }
DCLayoutInfo >> lineBreak [

	y := y + lineHeight.
	x := lineStart + (self padding * depth).
	lineHeight := 0
]

{ #category : #'as yet unclassified' }
DCLayoutInfo >> lineHeight [

	^ lineHeight
]

{ #category : #'as yet unclassified' }
DCLayoutInfo >> lineHeight: aNumber [

	lineHeight := aNumber
]

{ #category : #'as yet unclassified' }
DCLayoutInfo >> lineStart: aNumber [

	lineStart := aNumber
]

{ #category : #'as yet unclassified' }
DCLayoutInfo >> measure: aMorph [

	| minBounds |
	minBounds := self minBoundsOf: aMorph.
	bounds := bounds quickMerge: minBounds.
	aMorph class = DCLineBreak
		ifTrue: [self lineBreak]
		ifFalse: [aMorph class = DCBlock ifFalse: [self advance: minBounds width @ (minBounds height + (self padding * 2))]]
]

{ #category : #'as yet unclassified' }
DCLayoutInfo >> measureRoot: aMorph at: aPoint [

	| line flushLine |
	self
		origin: aPoint;
		lineStart: aPoint x;
		padding: aMorph layoutInset.
	
	morphs := Array streamContents: [:s | aMorph allLayoutMorphsDo: [:b | s nextPut: b]].
	
	line := OrderedCollection new.
	baseline := 0.
	lineStartY := aPoint y - aMorph layoutInset asEdgeInsets top.
	
	flushLine := [
		line do: [:tuple | | bounds |
			bounds := tuple size = 3
				ifTrue: [tuple second @ (lineStartY + baseline) extent: tuple third]
				ifFalse: [tuple first nonExtraChildrenBounds expandBy: tuple first layoutInset asEdgeInsets].
			y := y max: bounds bottom].
		line removeAll.
		
		x := lineStart.
		lineStartY := y.
		baseline := 0].
	
	morphs viewAllButFirstAndLast do: [:m |
		true
			caseOf: {
				[m class = Array] -> [ | inset |
					"leave"
					line add: {m second. x}.
					inset := m second layoutInset asEdgeInsets.
					x := x + inset right.
					y := y - inset top.
					lineStart := lineStart - inset left].
				[m isLineBreak] -> [
					line add: {m. x. m minExtent}.
					flushLine value].
				[m class = DCBlock] -> [ | inset |
					inset := m layoutInset asEdgeInsets.
					x := x + inset left.
					y := y + inset top.
					lineStart := lineStart + inset left.
					baseline := baseline max: y - lineStartY]}
			otherwise: [ | extent |
				extent := m minExtent.
				line add: {m. x. extent}.
				x := x + extent x]].
	
	flushLine value.
	
	^ aPoint - aMorph layoutInset asEdgeInsets topLeft extent: (aMorph submorphBounds expandBy: aMorph layoutInset asEdgeInsets) extent
]

{ #category : #'as yet unclassified' }
DCLayoutInfo >> minBoundsOf: aMorph [

	| oldBounds |
	^ aMorph class = DCBlock
		ifTrue: [ | b |
			oldBounds := bounds.
			bounds := x @ y extent: 0 @ 0.
			b := (aMorph minBoundsWith: self) extendBy: self padding * 2.
			bounds := oldBounds.
			b]
		ifFalse: [self position extent: aMorph minExtent]
]

{ #category : #'as yet unclassified' }
DCLayoutInfo >> origin: aPoint [

	x := aPoint x.
	y := aPoint y.
	bounds := aPoint extent: 0 @ 0
]

{ #category : #'as yet unclassified' }
DCLayoutInfo >> padding [

	^ padding
]

{ #category : #'as yet unclassified' }
DCLayoutInfo >> padding: aNumber [

	padding := aNumber
]

{ #category : #'as yet unclassified' }
DCLayoutInfo >> place: aMorph [

	| minBounds |
	aMorph class = DCLineBreak ifTrue: [
		minBounds := self position extent: 0 @ aMorph minExtent y.
		aMorph setBoundsDirect: minBounds.
		self advance: aMorph minExtent.
		bounds := bounds quickMerge: minBounds.
		^ self lineBreak].
	
	minBounds := self copy minBoundsOf: aMorph.
	aMorph setBoundsDirect: minBounds.
	bounds := bounds quickMerge: minBounds.
	aMorph class = DCBlock ifTrue: [aMorph layoutWith: self] ifFalse: [
		aMorph doLayoutIn: minBounds.
		self advance: minBounds width @ (minBounds height + (self padding * 2))]
]

{ #category : #'as yet unclassified' }
DCLayoutInfo >> position [

	^ x @ y
]

{ #category : #'as yet unclassified' }
DCLayoutInfo >> x [

	^ x
]

{ #category : #'as yet unclassified' }
DCLayoutInfo >> x: aNumber [

	self assert: aNumber isNumber.
	x := aNumber
]

{ #category : #'as yet unclassified' }
DCLayoutInfo >> y [

	^ y
]

{ #category : #'as yet unclassified' }
DCLayoutInfo >> y: aNumber [

	self assert: aNumber isNumber.
	y := aNumber
]
