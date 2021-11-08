Class {
	#name : #SBJsPalette,
	#superclass : #SBTSPalette,
	#category : #'Sandblocks-Javascript'
}

{ #category : #'as yet unclassified' }
SBJsPalette class >> buildOn: aBuilder [ 

	aBuilder addHeader: 'Javascript'.
	
	aBuilder addSectionHeader: 'Fetch'.
	aBuilder addBlock: 'simple fetch' as: (SBJavascript parse: 'window.fetch("")').
	aBuilder addBlock: 'json fetch' as: (SBJavascript parse: 'window.fetch("", {headers: {"Content-Type": "application/json"}})').
	aBuilder addBlock: 'json fetch' as: (SBJsFetch new
		factory: SBJavascript new;
		url: 'http://...' params: (SBJavascript parse: '{headers: {"Content-Type": "application/json"}}') childSandblocks first).
]

{ #category : #'as yet unclassified' }
SBJsPalette class >> language [

	^ #javascript
]
