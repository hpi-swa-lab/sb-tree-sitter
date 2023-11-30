"
* replace:
	- block replacedParent -> replacement
	- replace block w replacement
	- embed --> replace block with marker (cmd!)
	- embed replacedParent -> marker
* uninstall
	- block replacedParent -> nil
	- replace replacement w block
	- embed -> replace marker with block
	- embed replacedParent -> nil
* move
	- block has replacedParent? move replacedParent
* delete
	- block has replacedParent? delete replacedParent
* changed ast and replacement gone?
	- uninstall will be called --> gotta make sure clean up
* changed ast and an embed is now a child?
	- move will be called --> replace the embed with the new parent?!??
		(watch (number))
		= (keyword (marker -> number))

		(watch (add (number) (number)))
		= (keyword (marker -> add))
"
Class {
	#name : #DCReplacement,
	#superclass : #SBBlock,
	#instVars : [
		'source',
		'language',
		'bindings',
		'collectEmbeds',
		'currentEmbeds'
	],
	#category : #'DomainCode-Parser'
}

{ #category : #'as yet unclassified' }
DCReplacement >> activeUninstall [

	self sandblockEditor do: (SBCombinedCommand newWith: {
		SBReplaceCommand new target: self replacer: self source.
		SBMutatePropertyCommand new
			target: self source;
			selector: #replacedParent;
			value: nil}).
	self source startInputAtEnd
]

{ #category : #'as yet unclassified' }
DCReplacement >> childrenDo: aBlock [

	self hasType
		ifTrue: [currentEmbeds do: aBlock]
		ifFalse: [self source baseChildren do: aBlock]
]

{ #category : #'as yet unclassified' }
DCReplacement >> contents [

	^ self source ifNotNil: #contents ifNil: ['']
]

{ #category : #'as yet unclassified' }
DCReplacement >> currentTextMorph [

	self submorphsDo: [:m | m isTextMorph ifTrue: [^ m]].
	^ nil
]

{ #category : #binding }
DCReplacement >> embed: aBlock [

	| shard |
	shard := DCShard new.
	self
		fromSource: [:source :repl | | block |
			block := aBlock value: source.
			shard update: block.
			currentEmbeds add: block]
		toSource: [:source :repl | ].
	^ shard
]

{ #category : #binding }
DCReplacement >> embedMany: aBlock onChange: anotherBlock [

	| shard current |
	shard := DCShard new.
	current := nil.
	self
		fromSource: [:source :repl | | new |
			new := (aBlock value: source) collect: #baseMorph.
			new do: [:block | currentEmbeds add: block].
			current = new ifFalse: [
				anotherBlock value: new.
				current := new]]
		toSource: [:source :repl | ].
	^ shard
]

{ #category : #binding }
DCReplacement >> fromSource: aBlock toSource: anotherBlock [

	bindings add: aBlock -> anotherBlock
]

{ #category : #'as yet unclassified' }
DCReplacement >> gapFor: aMorph [

	self allMorphsDo: [:m | (m valueOfProperty: #waitingFor) = aMorph ifTrue: [^ m]].
	^ nil
]

{ #category : #'as yet unclassified' }
DCReplacement >> hasType [

	^ self type notEmpty
]

{ #category : #'as yet unclassified' }
DCReplacement >> initialize [

	super initialize.
	bindings := OrderedCollection new.
	self
		changeTableLayout;
		listDirection: #leftToRight;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap
]

{ #category : #'as yet unclassified' }
DCReplacement >> isNode: aNode [

	^ self source = aNode
]

{ #category : #'as yet unclassified' }
DCReplacement >> isReplacement [

	^ true
]

{ #category : #'block api' }
DCReplacement >> isRootBlock [

	^ self source isRootBlock
]

{ #category : #'as yet unclassified' }
DCReplacement >> language [

	^ self source language
]

{ #category : #'as yet unclassified' }
DCReplacement >> language: aLanguage [

	language := aLanguage
]

{ #category : #'as yet unclassified' }
DCReplacement >> layoutCommands [

	^ SBAlgebraCommand container
		morph: self;
		data: (self submorphs collect: [:s | s layoutCommands] separatedBy: [SBAlgebraCommand softLine])
]

{ #category : #'as yet unclassified' }
DCReplacement >> passiveUninstall [

	| hadFocus |
	self uninstallEmbeds.
	self source ifNotNil: [self source replacedParent: nil].
	
	self sandblockEditor ifNil: [^ self].
	hadFocus := self sandblockEditor textFocus
		ifNotNil: [:t | (t ownerSatisfying: [:o | o = self]) notNil]
		ifNil: [false].
	self source ifNotNil: [self replaceBy: self source] ifNil: [self delete].
	
	hadFocus ifTrue: [self source startInputAtEnd]
]

{ #category : #'as yet unclassified' }
DCReplacement >> performAction: aSymbol [

	(self queryState performShortcut: aSymbol for: self source) ifTrue: [^ true].
	
	(super performAction: aSymbol) ifTrue: [^ true].
	
	^ false
]

{ #category : #'as yet unclassified' }
DCReplacement >> printOn: aStream [

	aStream nextPutAll: self className.
	aStream nextPut: $(.
	aStream print: self source.
	aStream nextPut: $)
]

{ #category : #'as yet unclassified' }
DCReplacement >> purpose [

	^ self valueOfProperty: #purpose
]

{ #category : #'as yet unclassified' }
DCReplacement >> purpose: aSymbol [

	self setProperty: #purpose toValue: aSymbol
]

{ #category : #'as yet unclassified' }
DCReplacement >> queryState [

	^ self rootBlock
		valueOfProperty: #queryState
		ifAbsentPut: [DCQueryState new rootBlock: self]
]

{ #category : #'as yet unclassified' }
DCReplacement >> range [

	^ self source ifNotNil: #range ifNil: [SBTSRange null]
]

{ #category : #'as yet unclassified' }
DCReplacement >> rootBlock [

	source isRootBlock ifTrue: [^ source].
	
	^ self ownerSatisfying: [:b | b isTSMorph and: [b type = self language rootRuleName]]
]

{ #category : #'as yet unclassified' }
DCReplacement >> showInQuery [

	^ self hasType
]

{ #category : #'as yet unclassified' }
DCReplacement >> siblingIndex [

	^ self submorphIndex
]

{ #category : #'as yet unclassified' }
DCReplacement >> source [

	^ source
]

{ #category : #'as yet unclassified' }
DCReplacement >> source: aBlock [

	source := aBlock.
	bindings do: [:assoc | assoc key value: self source value: self].
	self language: aBlock language
]

{ #category : #binding }
DCReplacement >> syncTextFrom: aClosure to: aTextBlock [

	self
		fromSource: [:source :repl | aTextBlock contents: (aClosure value: source) contents]
		toSource: [:source :repl | ].
	aTextBlock
		when: #keyStroke
		evaluate: [:e | (aClosure value: self source) replaceWith: aTextBlock contents]
]

{ #category : #'as yet unclassified' }
DCReplacement >> treeHash [

	^ self source treeHash
]

{ #category : #'as yet unclassified' }
DCReplacement >> treeLabel [

	^ self source ifNotNil: #treeLabel ifNil: ['']
]

{ #category : #'as yet unclassified' }
DCReplacement >> type [

	^ ''
]

{ #category : #'as yet unclassified' }
DCReplacement >> uninstallEmbeds [

	currentEmbeds ifNotNil: [:e | e do: [:embed | embed source ifNotNil: [:source | source baseParent addMorph: source asElementNumber: embed baseSiblingIndex]]]
]

{ #category : #'as yet unclassified' }
DCReplacement >> updateReplacement [

	currentEmbeds := OrderedCollection new.
	bindings do: [:assoc | assoc key value: self source value: self]
]

{ #category : #'as yet unclassified' }
DCReplacement >> updateSource [

	bindings do: [:assoc | assoc value value: self source value: self]
]
