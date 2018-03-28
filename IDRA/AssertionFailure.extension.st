Extension { #name : #AssertionFailure }

{ #category : #'*IDRA' }
AssertionFailure >> defaultAction [
	(IDRAMonitor  getInstance started) ifTrue: [ 
		IDRAMonitor getInstance handleError: self inContext: (self signalerContext copyStack) ]
]
