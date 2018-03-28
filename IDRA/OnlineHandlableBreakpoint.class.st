Class {
	#name : #OnlineHandlableBreakpoint,
	#superclass : #OnlineHandlableError,
	#category : #'IDRA-Exceptions'
}

{ #category : #exceptiondescription }
OnlineHandlableBreakpoint >> defaultAction [
	|copy |
	copy := self copyContext .
	copy := copy sender sender.
	[(IDRADebugger getInstance) handleBreakpoint: self inContext: copy] fork.
]
