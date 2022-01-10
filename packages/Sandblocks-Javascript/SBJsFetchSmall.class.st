Class {
	#name : #SBJsFetchSmall,
	#superclass : #SBJsFetch,
	#instVars : [
		'showExamples',
		'showExamplesButtonTxt'
	],
	#category : #'Sandblocks-Javascript'
}

{ #category : #'as yet unclassified' }
SBJsFetchSmall >> addExampleSection [

	showExamples ifTrue: [
		 | map |
		
			self addMorphBack: (SBRow new
				cellGap: cellGapConstant;
				addMorphBack: (SBStringMorph new contents: 'Examples');
				addMorphBack: (SBRow new cellGap: cellGapConstant)).
				
			method = #post ifTrue: [exampleMorph := self submorphs seventh].
			method = #get ifTrue: [exampleMorph := self submorphs sixth].
			map := Examples at: url, method asString ifAbsent: [].
			map ifNotNil: [ map keysDo: [:key | exampleMorph submorphs second addMorphBack: (map at: key) first]]]
]

{ #category : #'as yet unclassified' }
SBJsFetchSmall >> addHeaderAction [
	(headerMorph submorphs size) = 0 ifTrue: [
		headerMorph
			addMorphBack: (SBStringMorph new contents: 'Headers')].
		
	super addHeaderAction.
]

{ #category : #'as yet unclassified' }
SBJsFetchSmall >> addHeaderAction: key value: value [

	(headerMorph submorphs size) = 0 ifTrue: [
			headerMorph
				addMorphBack: (SBStringMorph new contents: 'Headers')].
			
	super addHeaderAction: key value: value.
]

{ #category : #'as yet unclassified' }
SBJsFetchSmall >> addParamAction [

	(paramMorph submorphs size) = 0 ifTrue: [
		paramMorph
			addMorphBack: (SBStringMorph new contents: 'Params')].
		
	super addParamAction.

]

{ #category : #'as yet unclassified' }
SBJsFetchSmall >> addParamAction: key value: value [

	(paramMorph submorphs size) = 0 ifTrue: [
		paramMorph
			addMorphBack: (SBStringMorph new contents: 'Params')].
		
	super addParamAction: key value: value.
]

{ #category : #'as yet unclassified' }
SBJsFetchSmall >> addParamSection: aParams [

	| s |
	self
		addMorphBack: (SBRow new
			cellGap: cellGapConstant);
		addMorphBack: (SBRow new
			cellGap: cellGapConstant).
	
	paramMorph := self submorphs fifth.
	params keysDo: [:key | self addParamAction: ((params at: key) key) asString  value:  ((params at: key) value) asString].
	
	"Whats have I done here :)"
	SBToggledCode comment: '' active: 0 do: {
		[
			params keysDo: [:key | | k v |
				k := (params at: key) submorphs first.
				v := (params at: key) submorphs second.
				self addParamAction: k contents value: v contents]]}.

	method = #get ifTrue: [
		s := url, method.
		Examples at: s
			ifPresent: [: e |
			e size > 0 ifTrue: [self addExampleSection]]].
]

{ #category : #'as yet unclassified' }
SBJsFetchSmall >> hideExamplesButton [
	^(SBButton new icon: SBIcon iconEye shortcut: nil do: [
				showExamples := true.
				(((self submorphs first) submorphs fourth) submorphs second) replaceBy: self showExamplesButton.
				self recreateFromMorphs])
]

{ #category : #'as yet unclassified' }
SBJsFetchSmall >> initCommons [
	"Setup shared UI elements"

	self
		addMorphBack: (SBRow new
			changeTableLayout;
			hResizing: #spaceFill;
			cellGap: cellGapConstant;
			addMorphBack: (SBStringMorph new contents: 'URL');
			addMorphBack: (SBTextBubble new
				hResizing: #spaceFill;
				contents: url);
			addMorphBack: (SBButton new icon: SBIcon iconPlay shortcut: nil do: [self send]);
			addMorphBack: (SBRow new
			cellGap: cellGapConstant;
			addMorphBack: (SBButton new
				color: (Color r: 0.0 g: 1 b: 0.0);
				icon: SBIcon iconPlus shortcut: nil do: [self promptAddPayload]);
			addMorphBack: (showExamples ifTrue: [self showExamplesButton] ifFalse: [self hideExamplesButton])));
			listDirection: #topToBottom;
			addMorphBack: SBRow new;
			addMorphBack: SBRow new.
			
	
	"Initialize the the morphs centrally for easier acces"
	urlMorph := self submorphs first.
	headerMorph := self submorphs second.
	
	headers ifNotNil: [headers keysDo: [:key | self addHeaderAction: key asString value: (headers at: key) asString]]
]

{ #category : #'as yet unclassified' }
SBJsFetchSmall >> initialize [
	super initialize.
	showExamples := false.
]

{ #category : #'as yet unclassified' }
SBJsFetchSmall >> promptAddPayload [
	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SBJsFetchSmall >> showExamplesButton [
	^(SBButton new icon: SBIcon iconEyeSlash shortcut: nil do: [
				showExamples := false.
				(((self submorphs first) submorphs fourth) submorphs second) replaceBy: self hideExamplesButton.
				self recreateFromMorphs])
]

{ #category : #'as yet unclassified' }
SBJsFetchSmall >> updateHeaders: aHeadersMorph [
"Loop through the headers morphs and update the headers map"
	| key value index |
	index := 0.
	aHeadersMorph do: [: header |
		index := index + 1.
		index > 1 ifTrue: [
		key := header submorphs first contents.
		value := header submorphs second contents.
		key ~= nil & (key ~= '') ifTrue: [headers at: key put: value]]]
]

{ #category : #'as yet unclassified' }
SBJsFetchSmall >> updateParams: aParamsMorph [
"Loop through the params morphs and update the param map"
	| key value index |
	index := 0.
	aParamsMorph do: [:paramMorph | 
		index := index + 1.
		index > 1 ifTrue: [
		key := paramMorph submorphs first contents.
		value := paramMorph submorphs second contents.
		(key ~= nil) & (key ~= '') ifTrue: [params at: (key, value) put: (key -> value)]]]
]

{ #category : #'as yet unclassified' }
SBJsFetchSmall >> values [
	^ self subclassResponsibility
]
