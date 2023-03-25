Class {
	#name : #SBTSReplacedBlockContainer,
	#superclass : #Morph,
	#category : #'Sandblocks-TreeSitter-Replacements'
}

{ #category : #'as yet unclassified' }
SBTSReplacedBlockContainer >> colorPolicy [

	^ self firstSubmorph colorPolicy
]

{ #category : #'as yet unclassified' }
SBTSReplacedBlockContainer >> initialize [

	super initialize.
	
	self
		layoutPolicy: SBAlgebraLayout new;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		color: Color transparent
]

{ #category : #'as yet unclassified' }
SBTSReplacedBlockContainer >> layoutCommands [

	^ SBAlgebraCommand container
		data: {self firstSubmorph layoutCommands};
		morph: self
]

{ #category : #'as yet unclassified' }
SBTSReplacedBlockContainer >> type [

	^ nil
]
