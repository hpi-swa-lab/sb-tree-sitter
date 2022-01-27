Class {
	#name : #SBTSProject,
	#superclass : #SBBlock,
	#instVars : [
		'directory'
	],
	#category : #'Sandblocks-TreeSitter'
}

{ #category : #'as yet unclassified' }
SBTSProject class >> for: aFolderPathString [

	^ self new directory: (FileDirectory on: aFolderPathString)
]

{ #category : #'as yet unclassified' }
SBTSProject >> directory: aDirectory [

	self example: [SBTSProject new] args: [{FileDirectory default}] label: 'example'.
	directory := aDirectory.
	
	self
		addMorphBack: (SBColumn new addAllMorphs: ((directory entries select: [:entry | SBGrammarLanguage allSubclasses anySatisfy: [:lang | lang fileSuffix = (FileDirectory extensionFor: entry name)]]) collect: [:entry |
			(SBTSFile filepath: (directory / entry name) fullName collapsed: true)
				hResizing: #spaceFill;
				vResizing: #shrinkWrap]));
		addMorphBack: (StringMorph new contents: 'no opened file')
]

{ #category : #'as yet unclassified' }
SBTSProject >> initialize [

	super initialize.
	
	self
		changeTableLayout;
		hResizing: #rigid;
		vResizing: #rigid;
		attachDecorator: SBResizableDecorator new;
		attachDecorator: SBForceMoveDecorator newConfigured
]

{ #category : #'as yet unclassified' }
SBTSProject >> openFile: aString [

	self halt
]
