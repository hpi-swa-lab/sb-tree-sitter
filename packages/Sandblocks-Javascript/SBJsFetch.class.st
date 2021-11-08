Class {
	#name : #SBJsFetch,
	#superclass : #SBInlineBlockReplace,
	#instVars : [
		'params'
	],
	#category : #'Sandblocks-Javascript'
}

{ #category : #'as yet unclassified' }
SBJsFetch class >> matchJs: aDictionary do: aBlock [
	<lang: #javascript match: '''(call_expression
	(member_expression
    	(identifier) @window
        (property_identifier) @fetch)
    (arguments
    	(string) @url
        (object) @params)) @call'>

	(aDictionary at: 'window') contents = 'window' ifFalse: [^ nil].
	(aDictionary at: 'fetch') contents = 'fetch' ifFalse: [^ nil].
	
	^ aBlock value: (aDictionary at: 'call') value: (self new
		url: (aDictionary at: 'url') childSandblocks first contents
		params: (aDictionary at: 'params'))
]

{ #category : #'as yet unclassified' }
SBJsFetch >> initialize [

	super initialize.
	
	self
		changeTableLayout;
		listDirection: #topToBottom
]

{ #category : #'as yet unclassified' }
SBJsFetch >> url: aString params: aBlock [

	params := aBlock sourceString.
	self
		addMorphBack: (SBRow new
			addMorphBack: (SBStringMorph new contents: 'URL: ');
			addMorphBack: (SBTextBubble new contents: aString));
		addMorphBack: (SBStringMorph new contents: params)
]

{ #category : #'as yet unclassified' }
SBJsFetch >> writeSourceOn: aStream [

	aStream nextPutAll: 'window.fetch("'.
	aStream nextPutAll: self firstSubmorph submorphs second contents.
	aStream nextPutAll: '", '.
	aStream nextPutAll: params.
	aStream nextPutAll: ')'
]
