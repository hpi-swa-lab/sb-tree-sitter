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

	showExamples ifTrue: [super addExampleSection]
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
	
	paramMorph := self submorphs sixth.
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
SBJsFetchSmall >> initCommons [
	"Setup shared UI elements"

	self
		addMorphBack: (SBRow new
			changeTableLayout;
			hResizing: #spaceFill;
			cellGap: cellGapConstant;
			addMorphBack: (SBStringMorph new contents: 'URL ');
			addMorphBack: (SBTextBubble new
				hResizing: #spaceFill;
				contents: url);
			addMorphBack: (SBButton new icon: SBIcon iconPlusCircle label: 'Send' do: [self send]));
		listDirection: #topToBottom;
		addMorphBack: (SBRow new
			cellGap: cellGapConstant;
			addMorphBack: (SBButton new
				color: (Color r: 0.0 g: 1 b: 0.0);
				icon: SBIcon iconPlusCircle label: 'Payload' do: [self promptAddPayload]);
			addMorphBack: (SBButton new icon: SBIcon iconSearch label: showExamplesButtonTxt do: [
				showExamples := showExamples not.
				showExamples
					ifTrue: [showExamplesButtonTxt := 'Hide Examples']
					ifFalse: [showExamplesButtonTxt := 'Show Examples'].
				self recreateFromMorphs]));
		addMorphBack: SBRow new;
		addMorphBack: SBRow new.
	
	"Initialize the the morphs centrally for easier acces"
	urlMorph := self submorphs first.
	headerMorph := self submorphs fourth.
	
	headers ifNotNil: [headers keysDo: [:key | self addHeaderAction: key asString value: (headers at: key) asString]]
]

{ #category : #'as yet unclassified' }
SBJsFetchSmall >> initialize [
	super initialize.
	showExamples := false.
	showExamplesButtonTxt := 'Show Examples'.
]

{ #category : #'as yet unclassified' }
SBJsFetchSmall >> promptAddPayload [
	| fetch index |
	fetch := (self owner owner owner).
	index := UIManager default chooseFrom: #(Header Param Body).
	index > 0
		ifTrue: [
			index caseOf: {
				[ 1 ] -> [ self addHeaderAction ].
				[ 2 ] -> [ self addParamAction ].
				"TODO: post impl"
				"[ #Body ] -> [ self addBody ]"  }].
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