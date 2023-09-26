Class {
	#name : #DCProjectView,
	#superclass : #SBBlock,
	#instVars : [
		'files'
	],
	#category : #'DomainCode-Core'
}

{ #category : #'as yet unclassified' }
DCProjectView class >> queryOpenProject: aRoot [
	<domainQuery>

	aRoot
		queryFirst: [:obj | obj class = DCProject and: [obj hasProp: #open]]
		ifFound: [:match | aRoot sandblockEditor openMorphInView: (self new project: match)]
		ifNone: []
]

{ #category : #'as yet unclassified' }
DCProjectView >> openFile: aFile [

	self submorphCount > 1 ifTrue: [self lastSubmorph delete].
	self addMorphBack: (DCFileEditor new file: aFile)
]

{ #category : #'as yet unclassified' }
DCProjectView >> project: aProject [

	self
		changeTableLayout;
		hResizing: #rigid;
		vResizing: #shrinkWrap;
		listDirection: #leftToRight;
		layoutInset: 8;
		width: 600;
		attachDecorator: SBForceMoveDecorator newConfigured;
		attachDecorator: SBResizableDecorator new;
		addMorphBack: (files := SBColumn new).
	
	aProject
		queryFirst: [:obj | obj class = FSReference and: [obj = aProject directory]]
		ifFound: [:rootFile | files addMorphBack: ((SBFileTree new on: rootFile) when: #open send: #openFile: to: self)]
		ifNone: []
]
