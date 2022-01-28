Class {
	#name : #SBPyPltSubplots,
	#superclass : #SBInlineBlockReplace,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltSubplots class >> matchPython: aDictionary do: aBlock [
"TODO: replace arg of createFigureButtonFrom to enclosing node in aDictionary as soon as supported"
	
	^ aBlock
		value: (aDictionary at: 'initMatplotlib')
		value: (self new factory: (aDictionary at: 'initMatplotlib') factory; createFigureButtonFrom: (self nil))
]

{ #category : #'initialize-release' }
SBPyPltSubplots >> createFigureButtonFrom: aBlock [ 
	
	self submorphCount > 1 ifTrue: [self firstSubmorph delete].
	aBlock ifNotNil: [self 
			addMorph: (SBColumn new
				addMorphBack: (SBStringMorph new contents: 'Create Figure'; bold);
				addMorphBack: aBlock)]
]
