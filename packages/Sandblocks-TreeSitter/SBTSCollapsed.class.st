Class {
	#name : #SBTSCollapsed,
	#superclass : #SBTSReplacementBlock,
	#instVars : [
		'block'
	],
	#category : #'Sandblocks-TreeSitter-Replacements'
}

{ #category : #'as yet unclassified' }
SBTSCollapsed >> block: aBlock [

	block := aBlock.
	
	bindings := Dictionary newFrom: {'root' -> aBlock}.
	self slot: aBlock slot.
	
	self removeAllMorphs.
	self addMorphBack: (SBStringMorph new
		contents: (self language collapsedLabel: aBlock);
		opacity: 0.7;
		italic)
]

{ #category : #'as yet unclassified' }
SBTSCollapsed >> color [

	^ block color
]

{ #category : #'as yet unclassified' }
SBTSCollapsed >> doubleClick: evt [

	self uncollapseBlock
]

{ #category : #'as yet unclassified' }
SBTSCollapsed >> initialize [

	super initialize.
	
	self
		layoutInset: 2;
		changeTableLayout;
		cellGap: 4
]

{ #category : #'as yet unclassified' }
SBTSCollapsed >> printOn: aStream [

	aStream nextPutAll: 'collapsed '.
	aStream nextPutAll: (self type ifNil: [''])
]

{ #category : #'as yet unclassified' }
SBTSCollapsed >> type [

	^ block type
]

{ #category : #'as yet unclassified' }
SBTSCollapsed >> uncollapseBlock [
	<action>

	| cmd |
	cmd := SBReplaceCommand new target: self replacer: block.
	self sandblockEditor ifNil: [cmd do] ifNotNil: [:e | e do: cmd]
]
