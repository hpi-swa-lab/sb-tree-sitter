Class {
	#name : #SBJsRequestToolFieldTextBubble,
	#superclass : #SBJsRequestToolBodyTextBubble,
	#category : #'Sandblocks-RequestsTool'
}

{ #category : #'as yet unclassified' }
SBJsRequestToolFieldTextBubble >> initialize [
	super initialize.
]

{ #category : #'as yet unclassified' }
SBJsRequestToolFieldTextBubble >> promptChangeValue [

	| index key values placeholderTxt contentType |
	index := UIManager default chooseFrom: self values.
	
	index > 0 ifTrue: [
		key := self values at: index.
		key = 'Clear'
			ifTrue: [
				self contents: ''.
				owner owner owner recreateFromMorphs]
			ifFalse: [
				values := self valuesForKey: key.
				placeholderTxt := values at: 1.
				contentType := values at: 2.
				owner owner owner data: placeholderTxt.
				owner owner owner addHeaderAction: 'Content-Type' value: contentType.
				"Inverted case as in SBJsFetchBodyTextBubble"
				key = 'form-data' ifFalse: [owner owner owner isRawData: true].
				owner owner owner recreateFromMorphs]]
]

{ #category : #'as yet unclassified' }
SBJsRequestToolFieldTextBubble >> values [

	^ super values.
]
