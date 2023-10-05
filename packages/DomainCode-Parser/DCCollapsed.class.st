Class {
	#name : #DCCollapsed,
	#superclass : #DCReplacement,
	#category : #'DomainCode-Parser'
}

{ #category : #'as yet unclassified' }
DCCollapsed >> doubleClick: anEvent [

	self passiveUninstall.
	self source startInputAtEnd
]

{ #category : #'as yet unclassified' }
DCCollapsed >> initialize [

	super initialize.
	
	self addMorphBack: (SBStringMorph new contents: 'collapsed'; emphasis: TextEmphasis italic emphasisCode)
]

{ #category : #'as yet unclassified' }
DCCollapsed >> source: aBlock [

	super source: aBlock.
	
	self firstSubmorph contents: (aBlock sourceString sbSuggestionLimitedTo: 30 maxLines: 1)
]
