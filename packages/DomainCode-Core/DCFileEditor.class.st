Class {
	#name : #DCFileEditor,
	#superclass : #SBBlock,
	#instVars : [
		'file'
	],
	#category : #'DomainCode-Core'
}

{ #category : #'as yet unclassified' }
DCFileEditor >> file: aFile [

	file := aFile.
	
	self
		changeTableLayout;
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		addMorphBack: (ScrollPane new
			hResizing: #spaceFill;
			vResizing: #spaceFill;
			hScrollBarPolicy: #never;
			in: [:scroll |
				scroll scroller
					changeTableLayout;
					hResizing: #spaceFill;
					addMorphBack: ((SBTSFile languageForPathAskInstall: aFile basename)
						ifNotNil: [:language |
							(DCBlock parseBlock: file contents language: language)
								hResizing: #spaceFill;
								vResizing: #shrinkWrap]
						ifNil: [self shouldBeImplemented])];
			yourself)
]
