Class {
	#name : #SBJsRequestToolHeaderTextBubble,
	#superclass : #SBJsRequestToolTextBubble,
	#classVars : [
		'AllHeaders'
	],
	#category : #'Sandblocks-Javascript'
}

{ #category : #'as yet unclassified' }
SBJsRequestToolHeaderTextBubble >> collectHeaders [

	| client resp tmpIndex xmlDoc |
	AllHeaders := OrderedCollection new.
	client := WebClient new.
	resp := client httpGet: 'https://www.iana.org/assignments/message-headers/message-headers.xml'.
	AllHeaders add: 'Remove header'.
	AllHeaders add: 'Authorization'.
	
	xmlDoc := XMLDOMParser parseDocumentFrom: resp content readStream useNamespaces: true.
	tmpIndex := 1.
	"TODO: improve how to scan this XML response, make it safe"
	((xmlDoc elements at: 3) elements at: 3) elementsDo: [:currentElement |
		tmpIndex := tmpIndex + 1.
		tmpIndex > 7 ifTrue: [AllHeaders add: ((currentElement elementsAndContents at: 1) elementsAndContents at: 1) asString]].
	^ AllHeaders
]

{ #category : #'as yet unclassified' }
SBJsRequestToolHeaderTextBubble >> initialize [
	super initialize.
]

{ #category : #'as yet unclassified' }
SBJsRequestToolHeaderTextBubble >> promptChangeValue [

	| index key headersCopy fetch |
	index := UIManager default chooseFrom: self values.
	
	index > 0 ifTrue: [
		key := self values at: index.
		fetch := self owner owner owner.
		key ~= 'Remove header' ifTrue: [self contents: key. fetch recreateFromMorphs]].
		key = 'Remove header' ifTrue: [ 
			headersCopy := fetch headers deepCopy.
			headersCopy removeKey: (self owner submorphs first contents) ifAbsent: [].
			fetch headers: headersCopy.
			self owner delete.
			fetch recreateFromMorphs].
		
]

{ #category : #'as yet unclassified' }
SBJsRequestToolHeaderTextBubble >> values [
	^ AllHeaders ifNil: [self collectHeaders].
]
