Class {
	#name : #SBJsFetchHeaderTextBubble,
	#superclass : #SBJsFetchTextBubble,
	#classVars : [
		'AllHeaders'
	],
	#category : #'Sandblocks-Javascript'
}

{ #category : #'as yet unclassified' }
SBJsFetchHeaderTextBubble >> collectHeaders [
	AllHeaders = nil ifTrue: [ | resp client xmlDoc tmpIndex |
		AllHeaders := OrderedCollection new.
		client := WebClient new.
		resp := client httpGet: 'https://www.iana.org/assignments/message-headers/message-headers.xml'.
		
		xmlDoc := XMLDOMParser parseDocumentFrom: resp content readStream useNamespaces: true.
		tmpIndex := 1.
		"TODO: improve how to scan this XML response, make it safe"
		((xmlDoc elements at: 3) elements at: 3) elementsDo: [:currentElement |
			tmpIndex := tmpIndex + 1.
			tmpIndex > 7 ifTrue: [AllHeaders add: ((currentElement elementsAndContents at: 1) elementsAndContents at: 1) asString]].
		AllHeaders add: 'Remove header'.
		AllHeaders add: 'Authorization'].
	^AllHeaders.
]

{ #category : #'as yet unclassified' }
SBJsFetchHeaderTextBubble >> initialize [
	super initialize.
	self collectHeaders.
]

{ #category : #'as yet unclassified' }
SBJsFetchHeaderTextBubble >> promptChangeValue [

	| index key headersCopy fetch |
	index := UIManager default chooseFrom: self values.
	
	index > 0 ifTrue: [
		key := self values at: index.
		fetch := self owner owner owner.
		key ~= 'Remove header' ifTrue: [self contents: key. fetch recreateFromMorphs]].
		key = 'Remove header' ifTrue: [ 
			"This removes it from the examples!!!"
			"jsfetch headers removeKey: (self owner submorphs first contents) ifAbsent: []."
			headersCopy := fetch headers deepCopy.
			headersCopy removeKey: (self owner submorphs first contents) ifAbsent: [].
			fetch headers: headersCopy.
			self owner delete.
			fetch recreateFromMorphs].
		
]

{ #category : #'as yet unclassified' }
SBJsFetchHeaderTextBubble >> values [
	^ AllHeaders ifNil: [self collectHeaders].
]