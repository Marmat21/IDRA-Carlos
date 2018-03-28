Class {
	#name : #DefaultStrategy,
	#superclass : #RestartingStrategy,
	#category : #'IDRA-RestartingStrategies'
}

{ #category : #actions }
DefaultStrategy class >> restartSingleDebugSessionWithError: anError process: aProcess [
 "get the debugger"
	| debugSession stack foundContext |
	debugSession := aProcess proceedDebugSessionStartedAt: (anError signalerContext ).
	"get the stack"
	stack := debugSession interruptedContext.
	foundContext := nil.
	"look if the method selector is present in the stack"
	foundContext := IDRA findContextInAStack: stack.
	"if i found a context restart and proceed the debugSession from that context"
	foundContext isNotNil ifTrue: [ 
		debugSession restart: foundContext.
		debugSession resume.
	]
	"add the process back to the queue ifFalse"
	
	
]

{ #category : #actions }
DefaultStrategy class >> restartSingleDebugSessionWithoutProceedingWithError: anError process: aProcess [
 "get the debugger"
	| debugSession stack foundContext |
	debugSession := aProcess proceedDebugSessionStartedAt: (anError signalerContext ).
	"get the stack"
	stack := debugSession stack.
	foundContext := nil.
	"look if the method selector is present in the stack"
	foundContext := IDRA findContextInAStack: stack..
	"if i found a context restart and proceed the debugSession from that context"
	foundContext isNotNil ifTrue: [
		debugSession restart: foundContext.
	]
]

{ #category : #'as yet unclassified' }
DefaultStrategy class >> restartWithParameters: aParameter [
	
	| proceeding data process |
	proceeding := aParameter first.
	data := aParameter second.
	process := aParameter third.
	(data first) searchFrom: (data second).
	proceeding ifTrue: [ 
		self restartSingleDebugSessionWithError: (data first) process: process.
		] ifFalse: [ 
		self restartSingleDebugSessionWithoutProceedingWithError: (data first) process: process. ]
]
