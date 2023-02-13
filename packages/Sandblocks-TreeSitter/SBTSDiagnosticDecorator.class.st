Class {
	#name : #SBTSDiagnosticDecorator,
	#superclass : #SBBlockDecorator,
	#instVars : [
		'diagnostic'
	],
	#category : #'Sandblocks-TreeSitter-LanguageClient'
}

{ #category : #callbacks }
SBTSDiagnosticDecorator >> attached: aMorph [

	aMorph balloonText: self diagnostic message.
	super attached: aMorph
]

{ #category : #accessing }
SBTSDiagnosticDecorator >> color [

	^ (self diagnostic at: 'severity' ifAbsent: [1]) caseOf: {
		[1] -> ["Error"
		Color r: 1 g: 0.0 b: 0.0].
		[2] -> ["Warning"
		Color r: 1 g: 0.935 b: 0.0].
		[3] -> ["Information"
		Color r: 0.697 g: 1 b: 1].
		[4] -> ["Hint"
		Color r: 0.81 g: 0.935 b: 1]}
]

{ #category : #accessing }
SBTSDiagnosticDecorator >> diagnostic [

	^ diagnostic
]

{ #category : #accessing }
SBTSDiagnosticDecorator >> diagnostic: aJsonObject [

	diagnostic := aJsonObject
]

{ #category : #drawing }
SBTSDiagnosticDecorator >> postDrawOn: aCanvas [

	| policy |
	policy := self morph containingSandblock colorPolicy.
	aCanvas
		frameRoundRect: self morph bounds
		radius: policy cornerRadius
		width: policy selectionBorderWidth
		color: self color
]
