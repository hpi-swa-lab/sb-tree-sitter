Class {
	#name : #DCLayout,
	#superclass : #LayoutPolicy,
	#category : #'DomainCode-Parser'
}

{ #category : #'as yet unclassified' }
DCLayout >> layout: aMorph in: newBounds [

	| x y lineHeight line flushLine origin |
	origin := aMorph rootBlock topLeft.
	y := origin y.
	line := OrderedCollection new.
	flushLine := [
		x := origin x.
		line do: [:morph | | extent position |
			extent := morph minExtent.
			position := x @ (y + (lineHeight - extent y / 2)).
			morph setPositionFromLayout: position.
			morph setExtentFromLayout: extent.
			morph doLayoutIn: (position extent: extent).
			x := x + extent x].
		line removeAll.
		y := y + lineHeight.
		x := origin x.
		lineHeight := 0].
	
	lineHeight := 0.
	aMorph submorphsDo: [:morph | | extent |
		extent := morph minExtent.
		line add: morph.
		morph isLineBreak
			ifTrue: [flushLine value]
			ifFalse: [lineHeight := lineHeight max: extent y]].
	flushLine value
]

{ #category : #'as yet unclassified' }
DCLayout >> minExtentOf: aMorph in: newBounds [

	| x y lineHeight lineLength |
	x := 0.
	y := 0.
	lineHeight := 0.
	lineLength := 0.
	aMorph submorphsDo: [:morph | | extent |
		extent := morph minExtent.
		morph isLineBreak ifTrue: [
			y := y + lineHeight.
			lineHeight := 0.
			lineLength := lineLength max: x.
			x := 0].
		x := x + extent x.
		lineHeight := lineHeight max: extent y].
	y := y + lineHeight.
	lineLength := lineLength max: x.
	
	^ lineLength @ y
]
