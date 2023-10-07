Class {
	#name : #DCPreviewValue,
	#superclass : #DCReplacement,
	#instVars : [
		'value'
	],
	#category : #'DomainCode-Parser'
}

{ #category : #'as yet unclassified' }
DCPreviewValue >> drawnColor [

	^ Color veryDarkGray
]

{ #category : #'as yet unclassified' }
DCPreviewValue >> installFor: aBlock [

	aBlock installPassiveReplacement: self do: [:r |
		r
			addMorphBack: (r addEmbed: aBlock);
			addMorphBack: (SBMultilineOwnTextMorph new
				contents: r value printString;
				bold)]
]

{ #category : #'as yet unclassified' }
DCPreviewValue >> layoutCommands [

	^ SBAlgebraCommand container
		morph: self;
		data: (self submorphs
			collect: [:s | s layoutCommands]
			separatedBy: [SBAlgebraCommand hardLine withGap: true])
]

{ #category : #'as yet unclassified' }
DCPreviewValue >> layoutInset [

	^ 5
]

{ #category : #'as yet unclassified' }
DCPreviewValue >> value [

	^ value
]

{ #category : #'as yet unclassified' }
DCPreviewValue >> value: anObject [

	value := anObject
]
