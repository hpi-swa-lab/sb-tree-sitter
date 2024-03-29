Class {
	#name : #SBJsRequestToolBodyTextBubble,
	#superclass : #SBJsRequestToolTextBubble,
	#instVars : [
		'dict'
	],
	#category : #'Sandblocks-RequestsTool'
}

{ #category : #'as yet unclassified' }
SBJsRequestToolBodyTextBubble >> initMap [

	| map |
	map := Dictionary new.
	map at: 'Raw-JSON' put: #('{"key": "value"}' 'application/json').
	map at: 'Raw-Text' put: #('' 'text/plain').
	map at: 'Raw-HTML' put: #('' 'text/html').
	map at: 'Raw-JavaScript' put: #('' 'application/javascript').
	map at: 'form-data' put: #('' 'multipart/form-data').
	map at: 'Raw-XML' put: #('' 'application/xml').
	
	^ map
]

{ #category : #'as yet unclassified' }
SBJsRequestToolBodyTextBubble >> initialize [
	super initialize.
	dict := self initMap.
]

{ #category : #'as yet unclassified' }
SBJsRequestToolBodyTextBubble >> promptChangeValue [

	| index key values placeholderTxt contentType |
	index := UIManager default chooseFrom: self values.
	
	index > 0 ifTrue: [
		key := self values at: index.
		key = 'Remove Body'
			ifTrue: [ | fetch |
				fetch := owner owner.
				fetch bodyMorph: nil.
				fetch recreateFromVariables: fetch headers params: fetch params body: nil]
			ifFalse: [
				values := self valuesForKey: key.
				placeholderTxt := values at: 1.
				contentType := values at: 2.
				owner owner data: placeholderTxt.
				owner owner addHeaderAction: 'Content-Type' value: contentType.
				"Special cases when we need to change from text box to key / value pairs in the body section"
				key = 'form-data' ifTrue: [owner owner isRawData: false].
				owner owner recreateFromMorphs]]
]

{ #category : #'as yet unclassified' }
SBJsRequestToolBodyTextBubble >> values [

	^ #('Raw-JSON' 'Raw-Text' 'Raw-HTML' 'Raw-JavaScript' 'Raw-XML' 'form-data' 'Remove Body')
]

{ #category : #'as yet unclassified' }
SBJsRequestToolBodyTextBubble >> valuesForKey: key [
"Returns for the given key an array of 2 elements. First is the placeholder text and second the content-type value"
	^dict at: key.
]
