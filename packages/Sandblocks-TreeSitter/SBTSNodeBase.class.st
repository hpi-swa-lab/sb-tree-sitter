Class {
	#name : #SBTSNodeBase,
	#superclass : #SBBlock,
	#instVars : [
		'alias',
		'field',
		'factory',
		'parser'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSNodeBase >> addChild: aNode [

	self addMorphBack: aNode.
	parser := aNode parser
]

{ #category : #'as yet unclassified' }
SBTSNodeBase >> alias [

	^ alias
]

{ #category : #'as yet unclassified' }
SBTSNodeBase >> alias: aString [

	alias := aString
]

{ #category : #'as yet unclassified' }
SBTSNodeBase >> child [

	^ self firstSubmorph
]

{ #category : #'as yet unclassified' }
SBTSNodeBase >> copy [

	^ self class new
		field: field;
		alias: alias;
		factory: factory;
		parser: parser
]

{ #category : #'as yet unclassified' }
SBTSNodeBase >> factory [

	^ factory
]

{ #category : #'as yet unclassified' }
SBTSNodeBase >> factory: aFactory [

	factory := aFactory
]

{ #category : #'as yet unclassified' }
SBTSNodeBase >> field [

	^ field
]

{ #category : #'as yet unclassified' }
SBTSNodeBase >> field: aString [

	field := aString
]

{ #category : #'as yet unclassified' }
SBTSNodeBase >> lastChild [

	^ self lastSubmorph
]

{ #category : #'as yet unclassified' }
SBTSNodeBase >> parser [

	^ parser
]

{ #category : #'as yet unclassified' }
SBTSNodeBase >> parser: aParser [

	parser := aParser
]

{ #category : #'as yet unclassified' }
SBTSNodeBase >> resultsFor: aParser [

	^ self subclassResponsibility
]
