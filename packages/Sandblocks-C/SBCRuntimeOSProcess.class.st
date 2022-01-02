Class {
	#name : #SBCRuntimeOSProcess,
	#superclass : #SBTSLanguageRuntime,
	#category : #'Sandblocks-C'
}

{ #category : #'as yet unclassified' }
SBCRuntimeOSProcess >> evaluate: aString [

	| node |
	node := self which: 'node'.
	node ifNil: [^ self error: 'node executable not found'].
	
	^ self
		tmpFile: aString
		do: [:path | self spawnWatchDuring: [:port | self checkedCmd: node arguments: {path} env: {'SQ_WATCH' -> port} stdin: nil]]
]

{ #category : #'as yet unclassified' }
SBCRuntimeOSProcess >> evaluateFileAsync: aString cancel: aBlock [

	| cc ret |
	cc := self which: 'clang'.
	cc ifNil: [^ self error: 'clang compiler not found'].
	
	self checkedCmd: cc arguments: {aString} env: nil stdin: nil.
	
	ret := Promise new.
	[self spawnWatchDuring: [:port | ret resolveWith: (self cmd: './a.out' arguments: nil env: {'SQ_WATCH' -> port} stdin: nil cancel: aBlock) wait]] fork.
	^ ret
]

{ #category : #'as yet unclassified' }
SBCRuntimeOSProcess >> prettyPrint: aString [

	| prettier |
	prettier := self which: 'clang-format'.
	prettier ifNil: [^ aString].
	
	^ self checkedCmd: prettier arguments: {'--style=Google'} env: nil stdin: aString
]

{ #category : #'as yet unclassified' }
SBCRuntimeOSProcess >> writeWatchSourceOn: aStream watch: aWatch [

	'#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <arpa/inet.h>
int SQ_REPORT(char *id, int expr) {
  int s = socket(AF_INET , SOCK_STREAM , 0);
  if (s == -1) { perror("creating socket"); return 0; }

  struct sockaddr_in server;
  server.sin_addr.s_addr = inet_addr("127.0.0.1");
  server.sin_family = AF_INET;
  server.sin_port = htons(atoi(getenv("SQ_WATCH")));
  if (connect(s , &server, sizeof(server)) < 0) { perror("connect"); return 0; }

  char *data;
  asprintf(&data, "{\"id\":\"%s\",\"expression\":\"%i\"}", id, expr);
  if (send(s, data, strlen(data), 0) < 0) {perror("Send failed"); }
  return expr;
}'.
	aStream
		nextPutAll: 'SQ_REPORT("';
		nextPutAll: aWatch id;
		nextPutAll: '", '.
	aWatch expression writeSourceOn: aStream.
	aStream nextPutAll: ')'
]
