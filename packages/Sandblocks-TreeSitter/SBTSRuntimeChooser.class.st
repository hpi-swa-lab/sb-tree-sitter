Class {
	#name : #SBTSRuntimeChooser,
	#superclass : #SBComboBox,
	#category : #'Sandblocks-TreeSitter-Files'
}

{ #category : #'as yet unclassified' }
SBTSRuntimeChooser >> actionProviders [

	^ {self object}, super actionProviders
]

{ #category : #'as yet unclassified' }
SBTSRuntimeChooser >> language: aLanguageClass [

	| runtimes |
	runtimes := aLanguageClass allRuntimes.
	self
		prefix: 'Runtime: ';
		values: runtimes;
		labels: (runtimes collect: #runtimeName);
		object: aLanguageClass defaultRuntimeClass
]
