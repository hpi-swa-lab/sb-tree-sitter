Class {
	#name : #SBTSBoundarySelectCommand,
	#superclass : #SBCommand,
	#instVars : [
		'boundary',
		'currentContent',
		'currentFixed'
	],
	#category : #'Sandblocks-TreeSitter-Utils'
}

{ #category : #'as yet unclassified' }
SBTSBoundarySelectCommand >> boundary: aMorph [

	self assert: aMorph notNil.
	boundary := aMorph
]

{ #category : #'as yet unclassified' }
SBTSBoundarySelectCommand >> do [

	boundary isTextMorph ifTrue: [
		currentContent := boundary contentsForEdit.
		currentFixed := boundary fixedText.
		boundary confirmFixedText].
	^ boundary
]

{ #category : #'as yet unclassified' }
SBTSBoundarySelectCommand >> morphs [

	^ {}
]

{ #category : #'as yet unclassified' }
SBTSBoundarySelectCommand >> setArtefactFrom [

	^ boundary
]

{ #category : #'as yet unclassified' }
SBTSBoundarySelectCommand >> undo [

	boundary isTextMorph ifTrue: [
		boundary
			contents: currentContent;
			fixedText: currentFixed].
	^ boundary
]
