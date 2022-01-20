"
Base class which replaces source code with a tool to perform HTTP requests.
"
Class {
	#name : #SBJsEmbeddedRequestTool,
	#superclass : #SBJsRequestTool,
	#instVars : [
		'showExamples',
		'showExamplesButtonTxt',
		'sourceString',
		'sourceMorph'
	],
	#category : #'Sandblocks-Javascript'
}

{ #category : #'as yet unclassified' }
SBJsEmbeddedRequestTool >> addBodySection: aBody [

	| tmpUrl |
	self addMorphBack: SBRow new.
	bodyMorph := self submorphs fourth.
	aBody ifNotNil: [
		isRawData
			ifFalse: [
				bodyMorph
					addMorphBack: (SBStringMorph new contents: 'Body');
					addMorphBack: (SBButton new icon: SBIcon iconPlus label: 'Field' do: [self addFieldAction]);
					addMorphBack: (SBRow new
						cellGap: cellGapConstant;
						addMorphBack: (SBRow new
							cellGap: 0;
							addMorphBack: (SBJsRequestToolFieldTextBubble new
								cellGap: 0;
								placeholderText: 'key');
							addMorphBack: (SBTextBubble new
								cellGap: 0;
								placeholderText: 'value')))]
			ifTrue: [
				bodyMorph
					addMorphBack: (SBStringMorph new contents: 'Body');
					addMorphBack: (SBJsRequestToolBodyTextBubble new contents: aBody)].
		
		
		].
"TODO, improve tmpUrl workaround"
tmpUrl := 'http://localhost:8080', url.
Examples at: tmpUrl, method ifPresent: [:examples | examples size > 0 ifTrue: [self addExampleSection]].
]

{ #category : #'as yet unclassified' }
SBJsEmbeddedRequestTool >> addExampleSection [
	
	showExamples ifTrue: [
		 | map tmpUrl |
		
			self addMorphBack: (SBRow new
				cellGap: cellGapConstant;
				addMorphBack: (SBStringMorph new contents: 'Examples');
				addMorphBack: (SBRow new cellGap: cellGapConstant)).
				
			exampleMorph := self submorphs fourth.
			"TODO, improve tmpUrl workaround"
			tmpUrl := 'http://localhost:8080', url.
			
			map := Examples at: tmpUrl, method asString ifAbsent: [].
			map ifNotNil: [ map keysDo: [:key | exampleMorph submorphs second addMorphBack: (map at: key) first]]]
]

{ #category : #'as yet unclassified' }
SBJsEmbeddedRequestTool >> addHeaderAction [
	(headerMorph submorphs size) = 0 ifTrue: [
		headerMorph
			addMorphBack: (SBStringMorph new contents: 'Headers')].
		
	super addHeaderAction.
]

{ #category : #'as yet unclassified' }
SBJsEmbeddedRequestTool >> addHeaderAction: key value: value [

	(headerMorph submorphs size) = 0 ifTrue: [
			headerMorph
				addMorphBack: (SBStringMorph new contents: 'Headers')].
			
	super addHeaderAction: key value: value.
]

{ #category : #'as yet unclassified' }
SBJsEmbeddedRequestTool >> addParamAction [

	(paramMorph submorphs size) = 0 ifTrue: [
		paramMorph
			addMorphBack: (SBStringMorph new contents: 'Params')].
		
	super addParamAction.

]

{ #category : #'as yet unclassified' }
SBJsEmbeddedRequestTool >> addParamAction: key value: value [

	(paramMorph submorphs size) = 0 ifTrue: [
		paramMorph
			addMorphBack: (SBStringMorph new contents: 'Params')].
		
	super addParamAction: key value: value.
]

{ #category : #'as yet unclassified' }
SBJsEmbeddedRequestTool >> addParamSection: aParams [

	
	params keysDo: [:key | self addParamAction: ((params at: key) key) asString  value:  ((params at: key) value) asString].
	
	"Whats have I done here :)"
	SBToggledCode comment: '' active: 0 do: {
		[
			params keysDo: [:key | | k v |
				k := (params at: key) submorphs first.
				v := (params at: key) submorphs second.
				self addParamAction: k contents value: v contents]]}.

	method = #get ifTrue: [ | tmpUrl |
		"TODO, improve tmpUrl workaround"
		tmpUrl := 'http://localhost:8080', url, method.
		Examples at: tmpUrl
			ifPresent: [: e |
			e size > 0 ifTrue: [self addExampleSection]]].
]

{ #category : #'as yet unclassified' }
SBJsEmbeddedRequestTool >> drawnColor [

	^ Color veryLightGray.
]

{ #category : #'as yet unclassified' }
SBJsEmbeddedRequestTool >> hideExamplesButton [
	^(SBButton new icon: SBIcon iconEye shortcut: nil do: [
				showExamples := true.
				(((self submorphs first) submorphs fourth) submorphs second) replaceBy: self showExamplesButton.
				self recreateFromMorphs]; balloonText: 'Show Examples')
]

{ #category : #'as yet unclassified' }
SBJsEmbeddedRequestTool >> initCommons [
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
			addMorphBack: (SBButton new icon: SBIcon iconPlay shortcut: nil do: [self send]; balloonText: 'Send Request');
			addMorphBack: (SBRow new
			cellGap: cellGapConstant;
			addMorphBack: (SBButton new
				color: (Color r: 0.0 g: 1 b: 0.0);
				icon: SBIcon iconPlus shortcut: nil do: [self promptAddPayload]; balloonText: 'Add Data');
			addMorphBack: (showExamples ifTrue: [self showExamplesButton] ifFalse: [self hideExamplesButton])));
		listDirection: #topToBottom;
		addMorphBack: SBRow new;
		addMorphBack: SBRow new.
			
	
	"Initialize the the morphs centrally for easier acces"
	urlMorph := self submorphs first.
	headerMorph := self submorphs second.
	paramMorph := self submorphs third.
	
	headers ifNotNil: [headers keysDo: [:key | self addHeaderAction: key asString value: (headers at: key) asString]]
]

{ #category : #'as yet unclassified' }
SBJsEmbeddedRequestTool >> initPost [
	self
		initCommons;
		addParamSection: nil.

	"Init the body section and add it"
	self	addMorphBack: SBRow new.
	bodyMorph := self submorphs fourth.
	self addBodySection: data
	
	
]

{ #category : #'as yet unclassified' }
SBJsEmbeddedRequestTool >> initialize [
	super initialize.
	showExamples := false.
]

{ #category : #'as yet unclassified' }
SBJsEmbeddedRequestTool >> promptAddPayload [
	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SBJsEmbeddedRequestTool >> recreateFromVariables: aHeaders params: aParams body: aBody [
	super recreateFromVariables: aHeaders params: aParams body: aBody.
	self addMorphBack: (SBJavascript parse: ((sourceString) sourceString))
]

{ #category : #'as yet unclassified' }
SBJsEmbeddedRequestTool >> send [

	| paramsString |
	
	self updatePayloadInObjectInstance.
	paramsString := self collectParamsString.
	url := 'http://localhost:8080', url.

	method = #get ifTrue: [self performGetRequest: url asString, paramsString].
	method = #post ifTrue: [
		isRawData 
			ifTrue: [self performPostRequest: data url: url asString, paramsString]
			ifFalse: ["TODO: collect fields and perform request"]
	
	"TODO: implement other methods"]
]

{ #category : #'as yet unclassified' }
SBJsEmbeddedRequestTool >> showExamplesButton [
	^(SBButton new icon: SBIcon iconEyeSlash shortcut: nil do: [
				showExamples := false.
				(((self submorphs first) submorphs fourth) submorphs second) replaceBy: self hideExamplesButton.
				self recreateFromMorphs]; balloonText: 'Hide Examples')
]

{ #category : #'as yet unclassified' }
SBJsEmbeddedRequestTool >> source [
	^sourceString.
]

{ #category : #'as yet unclassified' }
SBJsEmbeddedRequestTool >> source: aSourceString [
	sourceString := aSourceString.
	
]

{ #category : #'as yet unclassified' }
SBJsEmbeddedRequestTool >> sourceMorph [
"TODO"
	^ sourceMorph.
	
]

{ #category : #'as yet unclassified' }
SBJsEmbeddedRequestTool >> sourceMorph: aSourceMorph [
"TODO"
	sourceMorph := aSourceMorph.
	
]

{ #category : #'as yet unclassified' }
SBJsEmbeddedRequestTool >> updateHeaders: aHeadersMorph [
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
SBJsEmbeddedRequestTool >> updateParams: aParamsMorph [
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
SBJsEmbeddedRequestTool >> values [
	^ self subclassResponsibility
]
