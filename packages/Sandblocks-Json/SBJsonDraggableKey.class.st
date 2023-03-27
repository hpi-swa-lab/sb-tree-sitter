Class {
	#name : #SBJsonDraggableKey,
	#superclass : #SBTSReplacementBlock,
	#category : #'Sandblocks-Json'
}

{ #category : #'as yet unclassified' }
SBJsonDraggableKey >> build [
	<lang: #json match: '(pair key: (string (string_content) @content) @root)' sample: '{"a": 2}'>

	self addMorphBack: (self createBinding: [SBOwnTextMorph new] contents: 'content')
]

{ #category : #'as yet unclassified' }
SBJsonDraggableKey >> pickUp: anEvent [

	anEvent hand grabMorph: (SBDragContainer new
		homeArtefact: nil;
		methodClass: nil;
		colorPolicy: self sandblockEditor colorPolicy;
		color: (self containingSandblock sandblockBlockColorIfAbsent: [Color r: 1 g: 1 b: 1]);
		addMorphBack: (SBJsonKey new source: self);
		yourself)
]

{ #category : #'as yet unclassified' }
SBJsonDraggableKey >> valid [

	^ true
]
