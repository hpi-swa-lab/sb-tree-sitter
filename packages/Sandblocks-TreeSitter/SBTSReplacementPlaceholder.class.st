Class {
	#name : #SBTSReplacementPlaceholder,
	#superclass : #Morph,
	#instVars : [
		'replaces'
	],
	#category : #'Sandblocks-TreeSitter-Replacements'
}

{ #category : #'as yet unclassified' }
SBTSReplacementPlaceholder >> contents [

	^ nil
]

{ #category : #'as yet unclassified' }
SBTSReplacementPlaceholder >> language [

	^ nil
]

{ #category : #'as yet unclassified' }
SBTSReplacementPlaceholder >> replaces [

	^ replaces
]

{ #category : #'as yet unclassified' }
SBTSReplacementPlaceholder >> replaces: aBlock [

	replaces := aBlock
]

{ #category : #'as yet unclassified' }
SBTSReplacementPlaceholder >> slot [

	^ SBTSSlot new
]

{ #category : #'as yet unclassified' }
SBTSReplacementPlaceholder >> type [

	^ nil
]
