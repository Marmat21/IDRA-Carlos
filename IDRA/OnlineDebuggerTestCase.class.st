Class {
	#name : #OnlineDebuggerTestCase,
	#superclass : #TestCase,
	#category : #'IDRA-Test'
}

{ #category : #'as yet unclassified' }
OnlineDebuggerTestCase >> tearDown [
	IDRADebugger getInstance stop
]

{ #category : #'as yet unclassified' }
OnlineDebuggerTestCase >> testErrorContextDoesNotContainOnFork2 [

	| observer debugger copyOfThis sender |
	debugger := MockDebugger new.
	observer := MockFailingObserver new.
	observer debugger: debugger.
	observer notifyWith: 1.
	
	Processor yield.
	copyOfThis := debugger capturedContext.
	sender := copyOfThis sender.
	[ sender isNotNil  ] whileTrue: [ 
		self deny: (sender selector == #on:forkAndCopyContext:).
		sender := sender sender.
	].

]

{ #category : #'as yet unclassified' }
OnlineDebuggerTestCase >> testErrorContextIsCopiedAndQueued [

	| observer debugger copyOfThis |
	debugger := MockDebugger new.
	observer := MockFailingObserver new.
	observer debugger: debugger.
	observer notifyWith: 1.
	
	Processor yield.
	copyOfThis := debugger capturedContext.
	8 timesRepeat: [ copyOfThis := copyOfThis sender ].
	
	self assert: copyOfThis selector equals: thisContext selector.
	self assert: copyOfThis receiver equals: thisContext receiver.
	self deny: copyOfThis == thisContext.
]

{ #category : #'as yet unclassified' }
OnlineDebuggerTestCase >> testErrorContextRunsInSeparateProcess [

	| observer debugger copyOfThis |
	debugger := MockDebugger new.
	observer := MockFailingObserver new.
	observer debugger: debugger.
	observer notifyWith: 1.
	
	Processor yield.
	
	self deny: (Processor activeProcess == debugger capturedProcess )
]

{ #category : #'as yet unclassified' }
OnlineDebuggerTestCase >> testErrorsAreCapturedByDebugger [

	| observer debugger |
	debugger := MockDebugger new.
	observer := MockFailingObserver new.
	observer debugger: debugger.
	observer notifyWith: 1.
	
	Processor yield.
	self assert: debugger capturedError class equals: Error.
]
