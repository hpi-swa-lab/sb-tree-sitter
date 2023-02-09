Class {
	#name : #SBTSLayoutState,
	#superclass : #Object,
	#instVars : [
		'x',
		'y',
		'maxX',
		'minX',
		'indent',
		'gap',
		'nextIsBreak'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSLayoutState >> bottomRight [

	^ x @ y
]

{ #category : #'as yet unclassified' }
SBTSLayoutState >> gap: aNumber [

	gap := aNumber
]

{ #category : #'as yet unclassified' }
SBTSLayoutState >> maxX: aNumber [

	maxX := aNumber
]

{ #category : #'as yet unclassified' }
SBTSLayoutState >> minX: aNumber [

	minX := aNumber.
	x := aNumber.
	y := 0.
	indent := 0.
	nextIsBreak := false
]

{ #category : #'as yet unclassified' }
SBTSLayoutState >> nextIsBreak: aBoolean [

	nextIsBreak := aBoolean
]

{ #category : #'as yet unclassified' }
SBTSLayoutState >> place: aMorph [

	| width dest extent break |
	extent := aMorph minExtent.
	width := extent x.
	dest := x @ y.
	x := x + (width + gap).
	
	aMorph contents = '}' ifTrue: [indent := indent - 1].
	break := x > maxX or: [nextIsBreak or: [aMorph contents = '}']].
	
	break ifTrue: [
		x := minX + (indent * 30).
		y := y + extent y.
		dest := x @ y.
		x := x + (width + gap).
		nextIsBreak := false].
	
	aMorph contents = '{' ifTrue: [
		nextIsBreak := true.
		indent := indent + 1].
	
	^ dest extent: extent
]

{ #category : #'as yet unclassified' }
SBTSLayoutState >> shouldRelayout: aMorph [

	| relayout |
	false ifTrue: [^ false].
	relayout := aMorph layoutComputed not or: [x ~= aMorph left or: [y ~= aMorph top]].
	relayout ifFalse: [ | s |
		s := aMorph layoutPolicy bottomRightLayoutState.
		x := s x.
		y := s y].
	^ relayout
]
