Class {
	#name : #SBTSSTMethodDeclaration,
	#superclass : #SBTSReplacementBlock,
	#category : #'Sandblocks-TSSmalltalk'
}

{ #category : #'as yet unclassified' }
SBTSSTMethodDeclaration >> build [
	<lang: #smalltalk match: '[(keyword_selector) (unary_selector)] @root' sample: 'test: aNumber'>

	self layoutPolicy: SBAlgebraLayout new.
	self addMorphBack: (SBStClassNameInput new
		object: self root parentSandblock parentSandblock methodClass;
		bordered: false).
	self addMorphBack: (SBStringMorph new contents: '>>').
	self addMorphBack: (self createBindingBlock: 'root')
]

{ #category : #'as yet unclassified' }
SBTSSTMethodDeclaration >> layoutCommands [

	^ SBAlgebraCommand container
		morph: self;
		data: (self submorphs collect: [:m | m layoutCommands])
]
