"
TextBubble subclass for the special case if the body type is form data a.k.a. fields.
"
Class {
	#name : #SBRequestToolFieldTextBubble,
	#superclass : #SBRequestToolBodyTextBubble,
	#category : #'Sandblocks-Javascript'
}

{ #category : #initialization }
SBRequestToolFieldTextBubble >> initialize [
	super initialize.
]

{ #category : #'event handling' }
SBRequestToolFieldTextBubble >> promptChangeValue [

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

{ #category : #accessing }
SBRequestToolFieldTextBubble >> values [

	^ super values.
]
