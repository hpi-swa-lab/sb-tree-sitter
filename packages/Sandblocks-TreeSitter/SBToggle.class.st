Class {
	#name : #SBToggle,
	#superclass : #SBTSReplacementBlock,
	#instVars : [
		'zeroBased'
	],
	#category : #'Sandblocks-TreeSitter-Replacements'
}

{ #category : #'as yet unclassified' }
SBToggle >> activeCheckbox: aCheckbox [

	self rowsDo: [:check :expr | check = aCheckbox ifFalse: [check value: false]].
	aCheckbox value: true.
	(bindings at: 'index') contents: ((self submorphs indexOf: aCheckbox owner) + (zeroBased ifTrue: [0] ifFalse: [1])) asString.
	self updateColorPolicy
]

{ #category : #'as yet unclassified' }
SBToggle >> activeIndex [

	self rowsDo: [:check :expr | check value ifTrue: [^ (self submorphs indexOf: check) + 1 // 2]].
	self assert: false
]

{ #category : #'as yet unclassified' }
SBToggle >> activeIndex: aNumber [

	self activeCheckbox: (self submorphs at: aNumber) firstSubmorph
]

{ #category : #'as yet unclassified' }
SBToggle >> buildChild: aBlock [

	| check |
	check := SBCheckbox new.
	check when: #toggled send: #activeCheckbox: to: self with: check.
	^ SBRowBlock new
		addAllMorphs: {check. aBlock};
		yourself
]

{ #category : #'as yet unclassified' }
SBToggle >> buildTypeScript [
	<lang: #typescript match: '(call_expression (subscript_expression (array) @array (number) @index))' sample: '[() => __wrap__][0]()'>

	self
		createRepeatBindingFor: 'array'
		childQuery: '(arrow_function body: (_) @)'
		new: '() => _expr'
		build: [:e | self buildChild: e]
]

{ #category : #'as yet unclassified' }
SBToggle >> buildWing [
	<lang: #wing match: '(call (structured_access_expression (array_literal) @array (number) @index))' sample: '[() => {return __wrap__}][0]()'>

	self
		createRepeatBindingFor: 'array'
		childQuery: '(preflight_closure (block (return_statement (_) @)))'
		new: '() => {return _expr}'
		build: [:e | self buildChild: e]
]

{ #category : #'as yet unclassified' }
SBToggle >> buildWith: aCollection [

	| active |
	active := (bindings at: 'index') contents asNumber + 1.
	aCollection withIndexDo: [:expr :index | | check |
		check := SBCheckbox new value: index = active.
		check when: #toggled send: #activeCheckbox: to: self with: check.
		self addMorphBack: check.
		self addMorphBack: expr].
	self updateColorPolicy
]

{ #category : #'as yet unclassified' }
SBToggle >> drawnColor [

	^ Color white
]

{ #category : #'as yet unclassified' }
SBToggle >> initialize [

	super initialize.
	
	zeroBased := true.
	
	self
		layoutInset: 8;
		layoutPolicy: SBAlgebraLayout new;
		listDirection: #topToBottom
]

{ #category : #'as yet unclassified' }
SBToggle >> insertEmptyCommandRequestNear: aBlock before: aBoolean [

	| insert |
	insert := super insertEmptyCommandRequestNear: aBlock before: aBoolean.
	^ SBCombinedCommand newWith: {
		insert.
		SBMutatePropertyCommand new
			target: self;
			selector: #activeIndex;
			value: insert insertIndex.
		SBDoItCommand new do: [insert morph lastSubmorph firstSubmorph]}
]

{ #category : #'as yet unclassified' }
SBToggle >> layoutCommands [

	^ SBAlgebraCommand container
		data: (self submorphs
			collect: [:s | s layoutCommands]
			separatedBy: [SBAlgebraCommand hardLine withGap: true]);
		morph: self
]

{ #category : #'as yet unclassified' }
SBToggle >> postBuild [

	self activeIndex: (bindings at: 'index') contents asNumber + (zeroBased ifTrue: [1] ifFalse: [0]).
	self updateColorPolicy
]

{ #category : #'as yet unclassified' }
SBToggle >> rowsDo: aBlock [

	self submorphsDo: [:row | aBlock valueWithArguments: row submorphs]
]

{ #category : #'as yet unclassified' }
SBToggle >> updateColorPolicy [

	self rowsDo: [:check :expr |
		check value
			ifTrue: [expr firstSubmorph removeLocalColorPolicy]
			ifFalse: [expr firstSubmorph localColorPolicy: SBDisabledTheme new]]
]
