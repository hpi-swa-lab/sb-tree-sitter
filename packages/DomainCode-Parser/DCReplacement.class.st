Class {
	#name : #DCReplacement,
	#superclass : #DCBlock,
	#instVars : [
		'source',
		'bindings'
	],
	#category : #'DomainCode-Parser'
}

{ #category : #'as yet unclassified' }
DCReplacement >> children [

	^ self source children
]

{ #category : #'as yet unclassified' }
DCReplacement >> fromSource: aBlock toSource: anotherBlock [

	bindings add: aBlock -> anotherBlock
]

{ #category : #'as yet unclassified' }
DCReplacement >> initialize [

	super initialize.
	bindings := OrderedCollection new
]

{ #category : #'as yet unclassified' }
DCReplacement >> isNode: aNode [

	^ self source = aNode
]

{ #category : #'as yet unclassified' }
DCReplacement >> isReplacement [

	^ true
]

{ #category : #'as yet unclassified' }
DCReplacement >> layoutCommands [

	^ SBAlgebraCommand container
		morph: self;
		data: (self submorphs collect: [:s | s layoutCommands] separatedBy: [SBAlgebraCommand softLine])
]

{ #category : #'as yet unclassified' }
DCReplacement >> range [

	^ self source range
]

{ #category : #'as yet unclassified' }
DCReplacement >> source [

	^ source
]

{ #category : #'as yet unclassified' }
DCReplacement >> source: aBlock [

	source := aBlock.
	bindings do: [:assoc | assoc key value: self source value: self]
]

{ #category : #'as yet unclassified' }
DCReplacement >> treeHash [

	^ self source treeHash
]

{ #category : #'as yet unclassified' }
DCReplacement >> treeLabel [

	^ self source treeLabel
]

{ #category : #'as yet unclassified' }
DCReplacement >> type [

	^ self source type
]

{ #category : #'as yet unclassified' }
DCReplacement >> uninstall [

	| hadFocus |
	self parent ifNil: [^ self].
	hadFocus := self sandblockEditor textFocus
		ifNotNil: [:t | t hasAnyParent: self]
		ifNil: [false].
	
	self source replacedParent: nil.
	self replaceBy: self source.
	
	hadFocus ifTrue: [self source startInputAtEnd]
]

{ #category : #'as yet unclassified' }
DCReplacement >> updateSourceDuring: aBlock [

	bindings do: [:assoc | assoc value value: self source value: self].
	aBlock value
]

{ #category : #'as yet unclassified' }
DCReplacement >> writeSourceOn: aStream indent: aNumber forCompare: aBoolean [

	self updateSourceDuring: [self source writeSourceOn: aStream indent: aNumber forCompare: aBoolean]
]
