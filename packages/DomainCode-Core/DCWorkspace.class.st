Class {
	#name : #DCWorkspace,
	#superclass : #SBBlock,
	#instVars : [
		'projects'
	],
	#category : #'DomainCode-Core'
}

{ #category : #'as yet unclassified' }
DCWorkspace >> domainParent [

	^ nil
]

{ #category : #'as yet unclassified' }
DCWorkspace >> domainReferencesDo: aClosure [

	projects submorphsDo: aClosure
]

{ #category : #'as yet unclassified' }
DCWorkspace >> initialize [

	super initialize.
	
	self
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		changeTableLayout;
		addMorphBack: (SBButton new label: 'Open Project' do: [self openProject]);
		addMorphBack: (projects := SBColumn new)
]

{ #category : #'as yet unclassified' }
DCWorkspace >> openProject [
	<action>

	UIManager default chooseDirectory ifNotNil: [:directory | projects addMorphFront: (DCProject new directory: directory)]
]

{ #category : #'as yet unclassified' }
DCWorkspace >> projects [

	^ projects submorphs
]
