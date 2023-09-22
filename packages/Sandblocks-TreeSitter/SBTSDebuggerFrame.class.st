Class {
	#name : #SBTSDebuggerFrame,
	#superclass : #SBBlock,
	#instVars : [
		'frame'
	],
	#category : #'Sandblocks-TreeSitter-LanguageClient'
}

{ #category : #'as yet unclassified' }
SBTSDebuggerFrame >> for: aFrame [

	self
		changeTableLayout;
		hResizing: #spaceFill;
		vResizing: #shrinkWrap;
		listDirection: #leftToRight;
		cellGap: 8;
		addMorphBack: (SBStringMorph new contents: aFrame name).
	
	frame := aFrame.
	
	aFrame canRestart == true ifTrue: [
		self addMorphBack: (SBButton new
			icon: SBIcon iconRefresh do: [self triggerEvent: #restart with: aFrame id];
			makeSmall)]
]

{ #category : #'as yet unclassified' }
SBTSDebuggerFrame >> id [

	^ frame id
]

{ #category : #'as yet unclassified' }
SBTSDebuggerFrame >> wasSelected [

	self triggerEvent: #selected with: frame
]
