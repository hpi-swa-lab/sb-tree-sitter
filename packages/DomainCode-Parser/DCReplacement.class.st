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
	#superclass : #DCBlock,
	#instVars : [
		'source',
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
DCReplacement >> children [

	^ self source children
]

{ #category : #'as yet unclassified' }
DCReplacement >> contents [

	^ self source contents
]

{ #category : #'as yet unclassified' }
DCReplacement >> embed: aClosure [

	collectEmbeds := aClosure
]

{ #category : #'as yet unclassified' }
DCReplacement >> fromSource: aBlock toSource: anotherBlock [

	bindings add: aBlock -> anotherBlock
]

{ #category : #'as yet unclassified' }
DCReplacement >> gapFor: aMorph [

	self allMorphsDo: [:m | (m valueOfProperty: #waitingFor) = aMorph ifTrue: [^ m]].
	^ nil
]

{ #category : #'as yet unclassified' }
DCReplacement >> initialize [

	super initialize.
	bindings := OrderedCollection new.
	embeds := OrderedCollection new
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
DCReplacement >> passiveUninstall [

	| hadFocus |
	self source replacedParent: nil.
	currentEmbeds ifNotNil: [:e | e do: [:embed | embed replacedParent uninstall]].
	
	self sandblockEditor ifNil: [^ self].
	hadFocus := self sandblockEditor textFocus
		ifNotNil: [:t | t hasAnyParent: self]
		ifNil: [false].
	self replaceBy: self source.
	
	hadFocus ifTrue: [self source startInputAtEnd]
]

{ #category : #'as yet unclassified' }
DCReplacement >> printOn: aStream [

	aStream nextPutAll: self className.
	aStream nextPut: $(.
	super printOn: aStream.
	aStream nextPut: $)
]

{ #category : #'as yet unclassified' }
DCReplacement >> range [

	^ self source range
]

{ #category : #'as yet unclassified' }
DCReplacement >> resolveSource [

	^ self source resolveSource
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

	^ ''
]

{ #category : #'as yet unclassified' }
DCReplacement >> updateEmbeds [

	| newEmbeds |
	newEmbeds := collectEmbeds value: self source.
	currentEmbeds
		ifNil: [
			currentEmbeds := newEmbeds collect: [:embed |
				embed = self source
					ifFalse: [ | marker |
						marker := DCEmbedMarker new source: embed.
						embed replaceBy: marker.
						embed]
					ifTrue: [
						self assert: embed replacedParent = self.
						embed]]]
		ifNotNil: [
			newEmbeds do: [:e |
				self
					assert: e class ~= DCEmbedMarker
					description: 'use children to navigate the tree for embedding (selected marker block)'].
			currentEmbeds with: newEmbeds do: [:current :new |
				current = new ifFalse: [ | marker |
					current replacedParent uninstall.
					
					marker := DCEmbedMarker new source: new.
					new replaceBy: marker.
					self addMorphBack: new]].
			currentEmbeds := newEmbeds].
	
	^ currentEmbeds
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
