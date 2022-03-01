"
Text field for the headers in HTTP requests. Initially the headers will be collected from a central definition. Internet connection required to access definition from https://www.iana.org/assignments/message-headers/message-headers.xml
"
Class {
	#name : #SBRequestToolHeaderTextBubble,
	#superclass : #SBRequestToolTextBubble,
	#classVars : [
		'AllHeaders'
	],
	#category : #'Sandblocks-Javascript'
}

{ #category : #initialization }
SBRequestToolHeaderTextBubble >> collectHeaders [

	| client resp tmpIndex xmlDoc |
	AllHeaders := OrderedCollection new.
	client := WebClient new.
	resp := client httpGet: 'https://www.iana.org/assignments/message-headers/message-headers.xml'.
	AllHeaders add: 'Remove header'.
	AllHeaders add: 'Authorization'.
	AllHeaders add: 'Accept'.
	
	xmlDoc := XMLDOMParser parseDocumentFrom: resp content readStream useNamespaces: true.
	tmpIndex := 1.
	((xmlDoc elements at: 3) elements at: 3) elementsDo: [:currentElement |
		tmpIndex := tmpIndex + 1.
		tmpIndex > 7 ifTrue: [AllHeaders add: ((currentElement elementsAndContents at: 1) elementsAndContents at: 1) asString]].
	^ AllHeaders sort.
]

{ #category : #initialization }
SBRequestToolHeaderTextBubble >> initialize [
	super initialize.
]

{ #category : #'event handling' }
SBRequestToolHeaderTextBubble >> promptChangeValue [

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

{ #category : #accessing }
SBRequestToolHeaderTextBubble >> values [
	^ AllHeaders ifNil: [self collectHeaders]
]
