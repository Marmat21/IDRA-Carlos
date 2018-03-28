Extension { #name : #TestFailure }

{ #category : #'*IDRA' }
TestFailure >> defaultAction [
(IDRADebugger getInstance started) ifTrue: [ 
		IDRADebugger getInstance handleError: self inContext: (self signalerContext copyStack)] ifFalse: [ 
	Processor activeProcess
		debug: self signalerContext
		title: self description]
]
