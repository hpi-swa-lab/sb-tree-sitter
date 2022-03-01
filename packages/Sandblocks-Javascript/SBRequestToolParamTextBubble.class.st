"
Text field for the parameters in HTTP requests.
"
Class {
	#name : #SBRequestToolParamTextBubble,
	#superclass : #SBRequestToolTextBubble,
	#category : #'Sandblocks-Javascript'
}

{ #category : #initialization }
SBRequestToolParamTextBubble >> initialize [
	super initialize.
]

{ #category : #'event handling' }
SBRequestToolParamTextBubble >> promptChangeValue [

	| index key fetch paramsCopy |
	index := UIManager default chooseFrom: self values.
	index > 0 ifTrue: [
		key := self values at: index.
		fetch := self owner owner owner.
		key = 'Remove param' ifTrue: [ 
			paramsCopy := fetch params deepCopy.
			paramsCopy removeKey: ((self owner submorphs first contents) asString, (self owner submorphs second contents) asString) ifAbsent: [].
			fetch params: paramsCopy.
			self owner delete.
			fetch recreateFromMorphs]].
]

{ #category : #accessing }
SBRequestToolParamTextBubble >> values [

	^ #('Remove param')
]
