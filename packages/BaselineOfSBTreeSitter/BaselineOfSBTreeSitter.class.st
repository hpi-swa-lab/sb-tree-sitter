Class {
	#name : #BaselineOfSBTreeSitter,
	#superclass : #BaselineOf,
	#category : #BaselineOfSBTreeSitter
}

{ #category : #baseline }
BaselineOfSBTreeSitter >> baseline: spec [
	<baseline>

	spec for: #common do: [
		spec preLoadDoIt: #preload:package:.
		" smalltalk needed for the tool integration "
		spec baseline: 'Sandblocks' with: [
			spec
				repository: 'github://tom95/sandblocks/packages';
				loads: #('Sandblocks-Core' 'Sandblocks-Smalltalk')].
		spec project: 'FFI' with: [
			spec
				className: 'ConfigurationOfFFI';
				repository: 'http://www.squeaksource.com/MetacelloRepository';
				versionString: #development;
				loads: #('Core')].
		spec project: 'OSProcess' with: [
			spec
				className: 'ConfigurationOfOSProcess';
				repository: 'http://www.squeaksource.com/MetacelloRepository';
				versionString: #stable;
				loads: #('Core')].
		spec package: 'JSON' with: [
			spec
				file: 'JSON-ul.35';
				repository: 'https://www.squeaksource.com/JSON'].
		
		spec
			package: 'Sandblocks-TreeSitter' with: [spec requires: #('Sandblocks' 'FFI' 'JSON' 'OSProcess')];
			package: 'Sandblocks-Javascript' with: [spec requires: #('Sandblocks-TreeSitter')];
			package: 'Sandblocks-Python' with: [spec requires: #('Sandblocks-TreeSitter')];
			package: 'Sandblocks-Regex' with: [spec requires: #('Sandblocks-TreeSitter')];
			package: 'Sandblocks-Json' with: [spec requires: #('Sandblocks-TreeSitter')];
			package: 'Sandblocks-C' with: [spec requires: #('Sandblocks-TreeSitter')];
			package: 'Sandblocks-Vhdl' with: [spec requires: #('Sandblocks-TreeSitter')].
		
		spec
			group: 'default'
			with: #('Sandblocks-TreeSitter' 'Sandblocks-Javascript' 'Sandblocks-Python' 'Sandblocks-Regex' 'Sandblocks-Json' 'Sandblocks-C' 'Sandblocks-Vhdl')]
]

{ #category : #baseline }
BaselineOfSBTreeSitter >> preload: loader package: packageSpec [
	
	Installer squeakInbox
		install: 'Multilingual-ct.259'.
	(Installer url: 'https://tmbe.me/c/Regex-Core-ct.75.mcz') install
]

{ #category : #baseline }
BaselineOfSBTreeSitter >> projectClass [
	^ Smalltalk
		at: #MetacelloCypressBaselineProject
		ifAbsent: [super projectClass]
]
