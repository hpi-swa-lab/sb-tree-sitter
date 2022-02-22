Class {
	#name : #SBTSCollapsed,
	#superclass : #SBInlineBlockReplace,
	#instVars : [
		'block'
	],
	#category : #'Sandblocks-TreeSitter'
}

{ #category : #'as yet unclassified' }
SBTSCollapsed >> block: aBlock factory: aFactory [

	block := aBlock.
	factory := aFactory.
	
	self removeAllMorphs.
	self addMorphBack: (SBStringMorph new contents: '...').
	self addMorphBack: (SBStringMorph new
		contents: aBlock collapsedContent;
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
		layoutInset: 4;
		changeTableLayout;
		cellGap: 4
]

{ #category : #'as yet unclassified' }
SBTSCollapsed >> printOn: aStream [

	aStream nextPutAll: 'collapsed '.
	aStream nextPutAll: self type
]

{ #category : #'as yet unclassified' }
SBTSCollapsed >> type [

	^ block type
]

{ #category : #'as yet unclassified' }
SBTSCollapsed >> uncollapseBlock [
	<action>

	self sandblockEditor do: (SBReplaceCommand new target: self replacer: block)
]

{ #category : #'as yet unclassified' }
SBTSCollapsed >> writeSourceOn: aStream [

	self writeSourceOn: aStream indent: 0
]

{ #category : #'as yet unclassified' }
SBTSCollapsed >> writeSourceOn: aStream indent: aNumber [

	block writeSourceOn: aStream indent: aNumber
]
