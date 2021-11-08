Class {
	#name : #SBJsPalette,
	#superclass : #SBTSPalette,
	#category : #'Sandblocks-Javascript'
}

{ #category : #'as yet unclassified' }
SBJsPalette class >> buildOn: aContainer [

	aContainer addSectionHeader: 'Javascript'.
	aContainer addBlock: 'simple fetch' as: (SBJavascript parse: 'window.fetch("")').
	aContainer
		addBlock: 'json fetch'
		as: (SBJavascript parse: 'window.fetch("", {headers: {"Content-Type": "application/json"}})')
]

{ #category : #'as yet unclassified' }
SBJsPalette class >> language [

	^ #javascript
]
