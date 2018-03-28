Extension { #name : #UnhandledError }

{ #category : #'*IDRA' }
UnhandledError >> defaultAction [
	<reflective: #unhandledErrorDefaultAction:message:>
	
	[ ^IDRAMonitor  getInstance isDebuggingAll
		ifTrue: [ IDRAMonitor getInstance handleError: self exception inContext: self signalerContext  ]
		ifFalse: [ UIManager default unhandledErrorDefaultAction: self exception ] ]
		on: Error
		do: [ ^UIManager default unhandledErrorDefaultAction: self exception ]
]
