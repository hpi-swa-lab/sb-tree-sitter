"
This class palette is shown in every python context.
"
Class {
	#name : #SBPyPltPalette,
	#superclass : #SBTSPalette,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltPalette class >> buildOn: aBuilder [

	aBuilder addSectionHeader: 'Plot Customization'.
	aBuilder addBlock: 'Set title of x or y label' as: 
		(SBPyPltSetLabel new 
			factory: SBPython instance;
			createReplacement: 'Your X-Axis' ofAxis: 'x').
	aBuilder addBlock: 'Set limits of x or y label' as:
		(SBPyPltSetLim new
			factory: SBPython instance;
			createReplacementFrom: '0' to: '30' ofAxis: 'y').
	aBuilder addBlock: 'Set scale of x or y axis' as:
		(SBPyPltSetScale new
			factory: SBPython instance;
			createReplacement: 'linear' ofAxis: 'x').
			
	aBuilder addSectionHeader: 'Plots'.
	aBuilder addBlock: 'Add scatter plot' as:
		(SBPyPltScatter new factory: SBPython instance; createReplacementWithX: 'X' Y: 'Y').
	aBuilder addBlock: 'Add histogram' as:
		(SBPyPltHist new factory: SBPython instance; createReplacementWithX: 'X').
]

{ #category : #'as yet unclassified' }
SBPyPltPalette class >> language [

	^ #python
]
